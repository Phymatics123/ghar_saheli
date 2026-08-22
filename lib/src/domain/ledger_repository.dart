import 'package:drift/drift.dart';

import '../core/hlc.dart';
import '../core/money.dart';
import '../core/ulid.dart';
import '../data/database.dart';
import 'account_type.dart';
import 'chart_of_accounts.dart';
import 'ledger_event.dart';
import 'models.dart';
import 'recurring.dart';
import 'staff.dart';

/// Keys used in the `app_meta` table.
class MetaKeys {
  MetaKeys._();

  static const String deviceId = 'device.id';
  static const String lastHlc = 'clock.last_hlc';
  static const String seededVersion = 'seed.version';
}

/// Bumped when [kSeedAccounts] gains entries that existing installs should
/// also receive.
const int kSeedVersion = 1;

/// The only way anything writes to the ledger.
///
/// Two rules hold this together:
///
///  1. Every mutation becomes a [LedgerEvent] and goes through [applyEvent].
///     Nothing else touches the ledger tables. When family sync arrives, a
///     remote event walks the same path, so there is no second implementation
///     that can disagree with this one.
///  2. Every entry balances to zero before it is written. A ledger that can
///     hold an unbalanced entry will eventually show a wrong total, and the
///     user will never know which number to trust.
class LedgerRepository {
  LedgerRepository({
    required AppDatabase database,
    required HlcClock clock,
    required this.deviceId,
  })  : _db = database,
        _clock = clock;

  final AppDatabase _db;
  final HlcClock _clock;
  final String deviceId;

  AppDatabase get database => _db;

  // ---------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------

  /// Accounts with their live balances, ordered for display.
  ///
  /// Written as raw SQL rather than drift's aggregate builder because a
  /// `LEFT JOIN ... GROUP BY` with a filtered join condition is exactly the
  /// shape that is easiest to get subtly wrong through a query builder — an
  /// account whose only entry was voided must still appear, showing zero,
  /// rather than vanishing from the list.
  Stream<List<AccountBalance>> watchAccountBalances({
    AccountType? type,
    bool includeArchived = false,
    bool includeStaffAccounts = false,
  }) {
    final List<String> conditions = <String>[];
    final List<Variable<Object>> variables = <Variable<Object>>[];

    if (type != null) {
      conditions.add('a.type = ?');
      variables.add(Variable<int>(type.index));
    }
    if (!includeArchived) {
      conditions.add('a.is_archived = 0');
    }
    if (!includeStaffAccounts) {
      // Per-person salary and peshgi accounts are real and counted in every
      // total, but they do not belong in a picker asking "what did you spend
      // on" — that list should be Raashan and Bijli, not one row per employee.
      conditions.add("a.code NOT LIKE '$staffAccountPrefix%'");
    }

    final String where =
        conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    return _db
        .customSelect(
          'SELECT a.*, COALESCE(SUM(p.amount_minor), 0) AS balance_minor '
          'FROM accounts a '
          'LEFT JOIN postings p '
          '  ON p.account_id = a.id AND p.is_voided = 0 '
          '$where '
          'GROUP BY a.id '
          'ORDER BY a.type ASC, a.sort_order ASC, a.name ASC',
          variables: variables,
          readsFrom: <TableInfo<Table, Object?>>{_db.accounts, _db.postings},
        )
        .watch()
        .map((List<QueryRow> rows) => rows.map(_toAccountBalance).toList());
  }

  Future<List<AccountBalance>> accountBalances({
    AccountType? type,
    bool includeArchived = false,
  }) {
    return watchAccountBalances(type: type, includeArchived: includeArchived)
        .first;
  }

  AccountBalance _toAccountBalance(QueryRow row) {
    return AccountBalance(
      account: _db.accounts.map(row.data),
      rawBalance: Money(row.read<int>('balance_minor')),
    );
  }

  Future<Money> balanceOf(String accountId) async {
    final QueryRow row = await _db.customSelect(
      'SELECT COALESCE(SUM(amount_minor), 0) AS balance_minor '
      'FROM postings WHERE account_id = ? AND is_voided = 0',
      variables: <Variable<Object>>[Variable<String>(accountId)],
      readsFrom: <TableInfo<Table, Object?>>{_db.postings},
    ).getSingle();
    return Money(row.read<int>('balance_minor'));
  }

  Stream<Money> watchBalanceOf(String accountId) {
    return _db
        .customSelect(
          'SELECT COALESCE(SUM(amount_minor), 0) AS balance_minor '
          'FROM postings WHERE account_id = ? AND is_voided = 0',
          variables: <Variable<Object>>[Variable<String>(accountId)],
          readsFrom: <TableInfo<Table, Object?>>{_db.postings},
        )
        .watchSingle()
        .map((QueryRow row) => Money(row.read<int>('balance_minor')));
  }

  Future<AccountRow?> accountByCode(String code) {
    return (_db.select(_db.accounts)..where((Accounts a) => a.code.equals(code)))
        .getSingleOrNull();
  }

  Future<AccountRow?> accountById(String id) {
    return (_db.select(_db.accounts)..where((Accounts a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  /// Entries in a date range, newest first, with their lines resolved.
  ///
  /// Grouping happens in Dart. A joined query cannot be `LIMIT`ed by entry
  /// without a subquery, and a household's data is small enough that reading
  /// a window of rows and folding them here is both simpler and fast. Callers
  /// should pass a real window — a month, not all of history.
  Stream<List<EntryWithPostings>> watchEntries({
    DateTime? from,
    DateTime? to,
    int? limit,
    bool includeVoided = false,
  }) {
    final query = _db.select(_db.ledgerEntries).join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        _db.postings,
        _db.postings.entryId.equalsExp(_db.ledgerEntries.id),
      ),
      innerJoin(
        _db.accounts,
        _db.accounts.id.equalsExp(_db.postings.accountId),
      ),
    ]);

    if (!includeVoided) {
      query.where(_db.ledgerEntries.isVoided.equals(false));
    }
    if (from != null) {
      query.where(
        _db.ledgerEntries.occurredOn
            .isBiggerOrEqualValue(DraftEntry.dateOnly(from)),
      );
    }
    if (to != null) {
      query.where(
        _db.ledgerEntries.occurredOn
            .isSmallerOrEqualValue(DraftEntry.dateOnly(to)),
      );
    }

    query.orderBy(<OrderingTerm>[
      OrderingTerm.desc(_db.ledgerEntries.occurredOn),
      OrderingTerm.desc(_db.ledgerEntries.createdAtHlc),
      OrderingTerm.asc(_db.postings.position),
    ]);

    return query.watch().map((List<TypedResult> rows) {
      final List<EntryWithPostings> entries = <EntryWithPostings>[];
      final Map<String, List<PostingWithAccount>> lines =
          <String, List<PostingWithAccount>>{};
      final Map<String, LedgerEntryRow> headers = <String, LedgerEntryRow>{};
      final List<String> order = <String>[];

      for (final TypedResult row in rows) {
        final LedgerEntryRow entry = row.readTable(_db.ledgerEntries);
        if (!headers.containsKey(entry.id)) {
          headers[entry.id] = entry;
          lines[entry.id] = <PostingWithAccount>[];
          order.add(entry.id);
        }
        lines[entry.id]!.add(
          PostingWithAccount(
            posting: row.readTable(_db.postings),
            account: row.readTable(_db.accounts),
          ),
        );
      }

      for (final String id in order) {
        if (limit != null && entries.length >= limit) break;
        entries.add(
          EntryWithPostings(entry: headers[id]!, lines: lines[id]!),
        );
      }
      return entries;
    });
  }

  Future<EntryWithPostings?> entryById(String entryId) async {
    final List<EntryWithPostings> all = await watchEntries(
      includeVoided: true,
    ).first;
    for (final EntryWithPostings entry in all) {
      if (entry.id == entryId) return entry;
    }
    return null;
  }

  /// Income, expense and per-category totals between two dates inclusive.
  Future<PeriodSummary> summaryBetween(DateTime from, DateTime to) async {
    final DateTime start = DraftEntry.dateOnly(from);
    final DateTime end = DraftEntry.dateOnly(to);

    final List<QueryRow> rows = await _db.customSelect(
      'SELECT a.*, SUM(p.amount_minor) AS total_minor '
      'FROM postings p '
      'JOIN ledger_entries e ON e.id = p.entry_id '
      'JOIN accounts a ON a.id = p.account_id '
      'WHERE p.is_voided = 0 AND e.occurred_on >= ? AND e.occurred_on <= ? '
      '  AND a.type IN (?, ?) '
      'GROUP BY a.id '
      'HAVING SUM(p.amount_minor) != 0 '
      'ORDER BY ABS(SUM(p.amount_minor)) DESC',
      variables: <Variable<Object>>[
        Variable<DateTime>(start),
        Variable<DateTime>(end),
        Variable<int>(AccountType.income.index),
        Variable<int>(AccountType.expense.index),
      ],
      readsFrom: <TableInfo<Table, Object?>>{
        _db.postings,
        _db.ledgerEntries,
        _db.accounts,
      },
    ).get();

    int incomeMinor = 0;
    int expenseMinor = 0;
    final List<CategoryTotal> categories = <CategoryTotal>[];

    for (final QueryRow row in rows) {
      final AccountRow account = _db.accounts.map(row.data);
      final int total = row.read<int>('total_minor');

      if (account.type == AccountType.expense) {
        expenseMinor += total;
        categories.add(
          CategoryTotal(account: account, total: Money(total)),
        );
      } else {
        // Income sits as a credit, so flip it to read as a positive figure.
        incomeMinor += -total;
      }
    }

    return PeriodSummary(
      from: start,
      to: end,
      income: Money(incomeMinor),
      expense: Money(expenseMinor),
      byCategory: categories,
    );
  }

  Future<PeriodSummary> summaryForMonth(DateTime month) {
    final DateTime first = DateTime(month.year, month.month, 1);
    final DateTime last = DateTime(month.year, month.month + 1, 0);
    return summaryBetween(first, last);
  }

  /// Total held across every asset account — "what the household has".
  Stream<Money> watchNetCash() {
    return _db
        .customSelect(
          // Spendable assets only. A peshgi moves money from cash into a
          // staff advance account — both are assets, so counting the whole
          // asset side would leave this figure unchanged while the cash box
          // was actually emptier. "In hand" has to mean money that can still
          // be spent, or the forecast built on it is wrong too.
          'SELECT COALESCE(SUM(p.amount_minor), 0) AS balance_minor '
          'FROM postings p '
          'JOIN accounts a ON a.id = p.account_id '
          "WHERE p.is_voided = 0 AND a.type = ? "
          "  AND a.code NOT LIKE '$staffAccountPrefix%'",
          variables: <Variable<Object>>[
            Variable<int>(AccountType.asset.index),
          ],
          readsFrom: <TableInfo<Table, Object?>>{_db.postings, _db.accounts},
        )
        .watchSingle()
        .map((QueryRow row) => Money(row.read<int>('balance_minor')));
  }

  /// How much left each pocket on spending, between two dates.
  ///
  /// Answers "of this month's Rs 12,000, how much came out of cash and how
  /// much off the card" — which is a different question from what was spent
  /// on, and the one people ask when the cash tin looks emptier than expected.
  ///
  /// Only counts asset accounts credited by an entry that also debits an
  /// expense. Without that condition a transfer from cash to savings would
  /// read as money spent, when nothing left the household at all.
  Stream<List<AccountBalance>> watchSpendingBySource({
    required DateTime from,
    required DateTime to,
  }) {
    return _db
        .customSelect(
          'SELECT a.*, COALESCE(SUM(-p.amount_minor), 0) AS balance_minor '
          'FROM postings p '
          'JOIN accounts a ON a.id = p.account_id '
          'JOIN ledger_entries e ON e.id = p.entry_id '
          'WHERE p.is_voided = 0 '
          '  AND a.type = ? '
          '  AND p.amount_minor < 0 '
          '  AND e.occurred_on >= ? AND e.occurred_on <= ? '
          '  AND EXISTS ('
          '    SELECT 1 FROM postings x '
          '    JOIN accounts xa ON xa.id = x.account_id '
          '    WHERE x.entry_id = e.id AND xa.type = ? AND x.amount_minor > 0'
          '  ) '
          'GROUP BY a.id '
          'HAVING SUM(-p.amount_minor) > 0 '
          'ORDER BY balance_minor DESC',
          variables: <Variable<Object>>[
            Variable<int>(AccountType.asset.index),
            Variable<DateTime>(DraftEntry.dateOnly(from)),
            Variable<DateTime>(DraftEntry.dateOnly(to)),
            Variable<int>(AccountType.expense.index),
          ],
          readsFrom: <TableInfo<Table, Object?>>{
            _db.postings,
            _db.accounts,
            _db.ledgerEntries,
          },
        )
        .watch()
        .map((List<QueryRow> rows) => rows.map(_toAccountBalance).toList());
  }

  Stream<int> watchEventCount() {
    return _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM ledger_events',
          readsFrom: <TableInfo<Table, Object?>>{_db.ledgerEvents},
        )
        .watchSingle()
        .map((QueryRow row) => row.read<int>('c'));
  }

  // ---------------------------------------------------------------------
  // Writes — every one of these builds an event and hands it to applyEvent
  // ---------------------------------------------------------------------

  /// Records a general double-entry. All other write helpers funnel here.
  Future<String> recordEntry(DraftEntry draft) async {
    draft.validate();

    final String entryId = Ulid.generate();
    final LedgerEvent event = _localEvent(
      LedgerEventType.entryRecorded,
      <String, Object?>{
        'entryId': entryId,
        'occurredOn': draft.occurredOn.millisecondsSinceEpoch,
        'description': draft.description.trim(),
        'note': draft.note?.trim(),
        'postings': <Map<String, Object?>>[
          for (int i = 0; i < draft.postings.length; i++)
            <String, Object?>{
              'id': Ulid.generate(),
              'accountId': draft.postings[i].accountId,
              'amountMinor': draft.postings[i].amount.paisa,
              'memo': draft.postings[i].memo,
              'position': i,
            },
        ],
      },
    );

    await applyEvent(event);
    return entryId;
  }

  /// Money spent: the expense category is debited, the source account credited.
  ///
  /// This is the two-tap path Stage 1 is built on.
  Future<String> recordExpense({
    required String expenseAccountId,
    required String paidFromAccountId,
    required Money amount,
    String? description,
    String? note,
    DateTime? on,
  }) async {
    if (!amount.isPositive) {
      throw const LedgerValidationError('Amount must be more than zero.');
    }
    final AccountRow? category = await accountById(expenseAccountId);
    return recordEntry(
      DraftEntry(
        occurredOn: on,
        description: description?.trim().isNotEmpty == true
            ? description!.trim()
            : (category?.name ?? 'Expense'),
        note: note,
        postings: <DraftPosting>[
          DraftPosting(accountId: expenseAccountId, amount: amount),
          DraftPosting(accountId: paidFromAccountId, amount: -amount),
        ],
      ),
    );
  }

  /// Money received: the destination account is debited, income credited.
  Future<String> recordIncome({
    required String incomeAccountId,
    required String receivedIntoAccountId,
    required Money amount,
    String? description,
    String? note,
    DateTime? on,
  }) async {
    if (!amount.isPositive) {
      throw const LedgerValidationError('Amount must be more than zero.');
    }
    final AccountRow? source = await accountById(incomeAccountId);
    return recordEntry(
      DraftEntry(
        occurredOn: on,
        description: description?.trim().isNotEmpty == true
            ? description!.trim()
            : (source?.name ?? 'Income'),
        note: note,
        postings: <DraftPosting>[
          DraftPosting(accountId: receivedIntoAccountId, amount: amount),
          DraftPosting(accountId: incomeAccountId, amount: -amount),
        ],
      ),
    );
  }

  /// Moves money between two accounts the household holds — cash to bank,
  /// bank to savings. Net worth does not change.
  Future<String> recordTransfer({
    required String fromAccountId,
    required String toAccountId,
    required Money amount,
    String? description,
    DateTime? on,
  }) async {
    if (!amount.isPositive) {
      throw const LedgerValidationError('Amount must be more than zero.');
    }
    if (fromAccountId == toAccountId) {
      throw const LedgerValidationError(
        'Choose two different accounts to transfer between.',
      );
    }
    return recordEntry(
      DraftEntry(
        occurredOn: on,
        description: description ?? 'Transfer',
        postings: <DraftPosting>[
          DraftPosting(accountId: toAccountId, amount: amount),
          DraftPosting(accountId: fromAccountId, amount: -amount),
        ],
      ),
    );
  }

  /// Sets what an account already held before the app existed.
  ///
  /// Balanced against Opening Balance rather than invented as income, so the
  /// first month's income figure stays truthful.
  Future<String> setOpeningBalance({
    required String accountId,
    required Money amount,
    DateTime? on,
  }) {
    return recordEntry(
      DraftEntry(
        occurredOn: on,
        description: 'Opening balance',
        postings: <DraftPosting>[
          DraftPosting(accountId: accountId, amount: amount),
          DraftPosting(
            accountId: AccountCodes.idOf(AccountCodes.openingBalance),
            amount: -amount,
          ),
        ],
      ),
    );
  }

  /// Corrects an account to the figure the user says it actually holds.
  ///
  /// Posts the difference against Adjustment rather than editing history. If
  /// the cash tin says Rs 12,000 and the app says Rs 12,500, something went
  /// unrecorded — the honest record of that is a Rs 500 correction on today's
  /// date, not a silent rewrite of a number that was true when it was written.
  ///
  /// Does nothing when the figures already agree, so re-saving an unchanged
  /// balance does not litter the ledger with zero entries.
  Future<String?> setAccountBalance({
    required String accountId,
    required Money actual,
    DateTime? on,
  }) async {
    final Money current = await balanceOf(accountId);
    final Money difference = actual - current;
    if (difference.isZero) return null;

    return recordEntry(
      DraftEntry(
        occurredOn: on,
        description: 'Adjustment',
        postings: <DraftPosting>[
          DraftPosting(accountId: accountId, amount: difference),
          DraftPosting(
            accountId: AccountCodes.idOf(AccountCodes.adjustment),
            amount: -difference,
          ),
        ],
      ),
    );
  }

  /// Reverses an entry without erasing it.
  Future<void> voidEntry(String entryId) async {
    final LedgerEntryRow? entry = await (_db.select(_db.ledgerEntries)
          ..where((LedgerEntries e) => e.id.equals(entryId)))
        .getSingleOrNull();
    if (entry == null) {
      throw const LedgerValidationError('That entry no longer exists.');
    }
    if (entry.isVoided) return;

    await applyEvent(
      _localEvent(
        LedgerEventType.entryVoided,
        <String, Object?>{'entryId': entryId},
      ),
    );
  }

  Future<String> createAccount({
    required String name,
    required String nameUr,
    required AccountType type,
    String? iconKey,
    int? colorValue,
    String? parentId,
    int sortOrder = 500,
  }) async {
    if (name.trim().isEmpty) {
      throw const LedgerValidationError('The category needs a name.');
    }
    final String id = Ulid.generate();
    await applyEvent(
      _localEvent(
        LedgerEventType.accountCreated,
        <String, Object?>{
          'id': id,
          'code': 'user.$id',
          'name': name.trim(),
          'nameUr': nameUr.trim().isEmpty ? name.trim() : nameUr.trim(),
          'type': type.index,
          'iconKey': iconKey,
          'colorValue': colorValue,
          'parentId': parentId,
          'isSystem': false,
          'sortOrder': sortOrder,
        },
      ),
    );
    return id;
  }

  Future<void> renameAccount({
    required String accountId,
    String? name,
    String? nameUr,
    String? iconKey,
    int? colorValue,
  }) {
    return applyEvent(
      _localEvent(
        LedgerEventType.accountUpdated,
        <String, Object?>{
          'id': accountId,
          if (name != null) 'name': name.trim(),
          if (nameUr != null) 'nameUr': nameUr.trim(),
          if (iconKey != null) 'iconKey': iconKey,
          if (colorValue != null) 'colorValue': colorValue,
        },
      ),
    );
  }

  /// Hides an account from pickers. History that references it stays readable.
  Future<void> setAccountArchived(String accountId, bool archived) {
    return applyEvent(
      _localEvent(
        LedgerEventType.accountArchived,
        <String, Object?>{'id': accountId, 'archived': archived},
      ),
    );
  }

  // ---------------------------------------------------------------------
  // The event chokepoint
  // ---------------------------------------------------------------------

  LedgerEvent _localEvent(LedgerEventType type, Map<String, Object?> payload) {
    return LedgerEvent(
      id: Ulid.generate(),
      hlc: _clock.issue(),
      deviceId: deviceId,
      type: type,
      payload: payload,
    );
  }

  /// Appends [event] to the log and applies it to the ledger tables, in one
  /// database transaction.
  ///
  /// Idempotent by event id: replaying a log, or receiving the same event from
  /// two devices, changes nothing the second time. That property is what makes
  /// sync safe to retry, which is why it is here in Stage 0 rather than being
  /// bolted on when sync is built.
  Future<void> applyEvent(LedgerEvent event, {bool isRemote = false}) async {
    await _db.transaction(() async {
      final LedgerEventRow? seen = await (_db.select(_db.ledgerEvents)
            ..where((LedgerEvents e) => e.id.equals(event.id)))
          .getSingleOrNull();
      if (seen != null) return;

      await _db.into(_db.ledgerEvents).insert(
            LedgerEventsCompanion.insert(
              id: event.id,
              hlc: event.hlc.packed,
              deviceId: event.deviceId,
              type: event.type.index,
              payload: event.payloadJson,
              appliedAt: DateTime.now(),
              isRemote: Value<bool>(isRemote),
            ),
          );

      switch (event.type) {
        case LedgerEventType.entryRecorded:
          await _applyEntryRecorded(event);
        case LedgerEventType.entryVoided:
          await _applyEntryVoided(event);
        case LedgerEventType.accountCreated:
          await _applyAccountCreated(event);
        case LedgerEventType.accountUpdated:
          await _applyAccountUpdated(event);
        case LedgerEventType.accountArchived:
          await _applyAccountArchived(event);
        case LedgerEventType.templateSaved:
          await _applyTemplateSaved(event);
        case LedgerEventType.templateRemoved:
          await _applyTemplateRemoved(event);
        case LedgerEventType.templateConfirmed:
          await _applyTemplateConfirmed(event);
        case LedgerEventType.staffSaved:
          await _applyStaffSaved(event);
        case LedgerEventType.staffRemoved:
          await _applyStaffRemoved(event);
        case LedgerEventType.attendanceMarked:
          await _applyAttendanceMarked(event);
        case LedgerEventType.attendanceCleared:
          await _applyAttendanceCleared(event);
        case LedgerEventType.attendanceRangeMarked:
          await _applyAttendanceRangeMarked(event);
      }

      // Persisted with the event that advanced it, so the clock can never be
      // ahead of the log it stamped.
      await writeMeta(MetaKeys.lastHlc, _clock.current.packed);
    });
  }

  /// Entry point for Stage 4 sync: fold in events produced elsewhere.
  ///
  /// Applied in HLC order so causality is preserved regardless of the order
  /// they arrived over the wire.
  Future<void> ingestRemoteEvents(List<LedgerEvent> events) async {
    final List<LedgerEvent> ordered = List<LedgerEvent>.of(events)
      ..sort((LedgerEvent a, LedgerEvent b) => a.hlc.compareTo(b.hlc));
    for (final LedgerEvent event in ordered) {
      _clock.witness(event.hlc);
      await applyEvent(event, isRemote: true);
    }
  }

  /// Everything this device knows after [since], for handing to another
  /// device. Passing null exports the whole log.
  Future<List<LedgerEvent>> exportEvents({Hlc? since, int? limit}) async {
    final query = _db.select(_db.ledgerEvents);
    if (since != null) {
      query.where((LedgerEvents e) => e.hlc.isBiggerThanValue(since.packed));
    }
    query.orderBy(<OrderingTerm Function(LedgerEvents)>[
      (LedgerEvents e) => OrderingTerm.asc(e.hlc),
    ]);
    if (limit != null) query.limit(limit);

    final List<LedgerEventRow> rows = await query.get();
    return rows
        .map(
          (LedgerEventRow row) => LedgerEvent.fromRow(
            id: row.id,
            hlcPacked: row.hlc,
            deviceId: row.deviceId,
            type: row.type,
            payloadJson: row.payload,
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------
  // Event handlers — the only code that mutates ledger tables
  // ---------------------------------------------------------------------

  Future<void> _applyEntryRecorded(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    final String entryId = payload['entryId']! as String;

    await _db.into(_db.ledgerEntries).insert(
          LedgerEntriesCompanion.insert(
            id: entryId,
            occurredOn: DateTime.fromMillisecondsSinceEpoch(
              payload['occurredOn']! as int,
            ),
            description: payload['description']! as String,
            note: Value<String?>(payload['note'] as String?),
            createdAtHlc: event.hlc.packed,
            deviceId: event.deviceId,
          ),
          mode: InsertMode.insertOrIgnore,
        );

    final List<Object?> postings = payload['postings']! as List<Object?>;
    for (final Object? raw in postings) {
      final Map<String, Object?> line = (raw! as Map<Object?, Object?>)
          .cast<String, Object?>();
      await _db.into(_db.postings).insert(
            PostingsCompanion.insert(
              id: line['id']! as String,
              entryId: entryId,
              accountId: line['accountId']! as String,
              amountMinor: line['amountMinor']! as int,
              memo: Value<String?>(line['memo'] as String?),
              position: Value<int>((line['position'] as int?) ?? 0),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<void> _applyEntryVoided(LedgerEvent event) async {
    final String entryId = event.payload['entryId']! as String;

    await (_db.update(_db.ledgerEntries)
          ..where((LedgerEntries e) => e.id.equals(entryId)))
        .write(
      LedgerEntriesCompanion(
        isVoided: const Value<bool>(true),
        voidedByEventId: Value<String?>(event.id),
      ),
    );

    // Keep the mirrored flag on postings in step — balances read it directly.
    await (_db.update(_db.postings)
          ..where((Postings p) => p.entryId.equals(entryId)))
        .write(const PostingsCompanion(isVoided: Value<bool>(true)));
  }

  Future<void> _applyAccountCreated(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    await _db.into(_db.accounts).insert(
          AccountsCompanion.insert(
            id: payload['id']! as String,
            code: payload['code']! as String,
            name: payload['name']! as String,
            nameUr: payload['nameUr']! as String,
            type: AccountType.values[payload['type']! as int],
            parentId: Value<String?>(payload['parentId'] as String?),
            iconKey: Value<String?>(payload['iconKey'] as String?),
            colorValue: Value<int?>(payload['colorValue'] as int?),
            isSystem: Value<bool>((payload['isSystem'] as bool?) ?? false),
            sortOrder: Value<int>((payload['sortOrder'] as int?) ?? 500),
            createdAtHlc: event.hlc.packed,
            updatedAtHlc: event.hlc.packed,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _applyAccountUpdated(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    final String id = payload['id']! as String;

    await (_db.update(_db.accounts)..where((Accounts a) => a.id.equals(id)))
        .write(
      AccountsCompanion(
        name: payload.containsKey('name')
            ? Value<String>(payload['name']! as String)
            : const Value<String>.absent(),
        nameUr: payload.containsKey('nameUr')
            ? Value<String>(payload['nameUr']! as String)
            : const Value<String>.absent(),
        iconKey: payload.containsKey('iconKey')
            ? Value<String?>(payload['iconKey'] as String?)
            : const Value<String?>.absent(),
        colorValue: payload.containsKey('colorValue')
            ? Value<int?>(payload['colorValue'] as int?)
            : const Value<int?>.absent(),
        updatedAtHlc: Value<String>(event.hlc.packed),
      ),
    );
  }

  Future<void> _applyAccountArchived(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    await (_db.update(_db.accounts)
          ..where((Accounts a) => a.id.equals(payload['id']! as String)))
        .write(
      AccountsCompanion(
        isArchived: Value<bool>((payload['archived'] as bool?) ?? true),
        updatedAtHlc: Value<String>(event.hlc.packed),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Recurring templates
  // ---------------------------------------------------------------------

  /// Every template the user has set up, active first.
  Stream<List<DueTemplate>> watchTemplates({bool onlyActive = true}) {
    return _watchTemplateRows(onlyActive: onlyActive);
  }

  /// Templates waiting to be confirmed for the month that is running now.
  ///
  /// A template is due when its day has arrived and it has not been stamped for
  /// this month yet. Only the current month is ever offered — if July's rent
  /// was never confirmed, this does not quietly post it in August. Whether a
  /// bill from a past month was actually paid is not something the app can
  /// know, and guessing would put an invented entry in someone's ledger.
  Stream<List<DueTemplate>> watchDueTemplates() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final String period = MonthPeriod.of(today);

    return _watchTemplateRows(onlyActive: true).map(
      (List<DueTemplate> all) => all.where((DueTemplate t) {
        if (t.template.lastPostedPeriod == period) return false;
        return !t.dueDate.isAfter(today);
      }).toList(),
    );
  }

  /// Joins templates to the two accounts each one points at.
  ///
  /// Both joins hit the accounts table, so each needs its own alias — without
  /// them SQLite cannot tell which `accounts.name` is the category and which is
  /// the pocket it is paid from.
  Stream<List<DueTemplate>> _watchTemplateRows({required bool onlyActive}) {
    final $AccountsTable category = _db.accounts.createAlias('cat');
    final $AccountsTable source = _db.accounts.createAlias('src');

    final query =
        _db.select(_db.recurringTemplates).join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        category,
        category.id.equalsExp(_db.recurringTemplates.categoryAccountId),
      ),
      innerJoin(
        source,
        source.id.equalsExp(_db.recurringTemplates.sourceAccountId),
      ),
    ]);

    if (onlyActive) {
      query.where(_db.recurringTemplates.isActive.equals(true));
    }
    query.orderBy(<OrderingTerm>[
      OrderingTerm.asc(_db.recurringTemplates.dayOfMonth),
    ]);

    final DateTime now = DateTime.now();

    return query.watch().map((List<TypedResult> rows) {
      return rows.map((TypedResult row) {
        final RecurringTemplateRow template =
            row.readTable(_db.recurringTemplates);
        return DueTemplate(
          template: template,
          category: row.readTable(category),
          source: row.readTable(source),
          dueDate: DateTime(
            now.year,
            now.month,
            clampDayToMonth(template.dayOfMonth, now),
          ),
        );
      }).toList();
    });
  }

  Future<String> saveTemplate({
    String? id,
    required RecurringKind kind,
    required String categoryAccountId,
    required String sourceAccountId,
    required Money amount,
    required String description,
    required int dayOfMonth,
  }) async {
    if (description.trim().isEmpty) {
      throw const LedgerValidationError('This needs a name.');
    }
    if (dayOfMonth < 1 || dayOfMonth > 31) {
      throw const LedgerValidationError('Pick a day between 1 and 31.');
    }

    final String templateId = id ?? Ulid.generate();
    await applyEvent(
      _localEvent(
        LedgerEventType.templateSaved,
        <String, Object?>{
          'id': templateId,
          'kind': kind.index,
          'categoryAccountId': categoryAccountId,
          'sourceAccountId': sourceAccountId,
          'amountMinor': amount.paisa,
          'description': description.trim(),
          'dayOfMonth': dayOfMonth,
        },
      ),
    );
    return templateId;
  }

  Future<void> removeTemplate(String templateId) {
    return applyEvent(
      _localEvent(
        LedgerEventType.templateRemoved,
        <String, Object?>{'id': templateId},
      ),
    );
  }

  /// Records the entry a due template describes, and stamps it done for the
  /// month so it stops being offered.
  ///
  /// Both halves go in as separate events but the stamp only happens once the
  /// entry is safely written — a crash in between leaves the template still
  /// due, which is the harmless direction to fail in. The alternative, stamping
  /// first, could lose a bill silently.
  Future<String> confirmTemplate({
    required DueTemplate due,
    Money? amount,
    DateTime? on,
  }) async {
    final Money value = amount ?? due.amount;
    if (!value.isPositive) {
      throw const LedgerValidationError('Enter an amount first.');
    }

    final DateTime date = on ?? due.dueDate;
    final String entryId = due.isExpense
        ? await recordExpense(
            expenseAccountId: due.category.id,
            paidFromAccountId: due.source.id,
            amount: value,
            description: due.template.description,
            on: date,
          )
        : await recordIncome(
            incomeAccountId: due.category.id,
            receivedIntoAccountId: due.source.id,
            amount: value,
            description: due.template.description,
            on: date,
          );

    await applyEvent(
      _localEvent(
        LedgerEventType.templateConfirmed,
        <String, Object?>{
          'id': due.template.id,
          'period': MonthPeriod.of(date),
        },
      ),
    );
    return entryId;
  }

  Future<void> _applyTemplateSaved(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    await _db.into(_db.recurringTemplates).insertOnConflictUpdate(
          RecurringTemplatesCompanion(
            id: Value<String>(payload['id']! as String),
            kind: Value<RecurringKind>(
              RecurringKind.values[payload['kind']! as int],
            ),
            categoryAccountId:
                Value<String>(payload['categoryAccountId']! as String),
            sourceAccountId:
                Value<String>(payload['sourceAccountId']! as String),
            amountMinor: Value<int>((payload['amountMinor'] as int?) ?? 0),
            description: Value<String>(payload['description']! as String),
            dayOfMonth: Value<int>(payload['dayOfMonth']! as int),
            isActive: const Value<bool>(true),
            createdAtHlc: Value<String>(event.hlc.packed),
            updatedAtHlc: Value<String>(event.hlc.packed),
          ),
        );
  }

  Future<void> _applyTemplateRemoved(LedgerEvent event) async {
    await (_db.delete(_db.recurringTemplates)
          ..where((RecurringTemplates t) =>
              t.id.equals(event.payload['id']! as String)))
        .go();
  }

  Future<void> _applyTemplateConfirmed(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    await (_db.update(_db.recurringTemplates)
          ..where(
              (RecurringTemplates t) => t.id.equals(payload['id']! as String)))
        .write(
      RecurringTemplatesCompanion(
        lastPostedPeriod: Value<String?>(payload['period'] as String?),
        updatedAtHlc: Value<String>(event.hlc.packed),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Household staff and peshgi
  // ---------------------------------------------------------------------

  /// Prefix on the account codes belonging to individual staff members.
  ///
  /// These accounts are real and appear in every balance and total, but they
  /// are kept out of the category and source pickers — a household picking
  /// "what did I spend on" should see Raashan and Bijli, not eleven rows of
  /// per-person salary accounts. Filtering on the code namespace needs no
  /// extra column and no migration.
  static const String staffAccountPrefix = 'staff.';

  /// Staff with their outstanding peshgi.
  ///
  /// The advance is a correlated subquery rather than a separate read, so that
  /// `postings` is part of what this stream watches. Fetching the balance
  /// afterwards left the figure stale: giving an advance writes postings, the
  /// query only depended on `staff_members`, and nothing told the screen to
  /// rebuild — so the peshgi total sat unchanged until the page was reopened.
  ///
  /// The accounts themselves are not joined in. Only their ids were ever used,
  /// and those already sit on the staff row.
  Stream<List<StaffWithAccounts>> watchStaff({bool onlyActive = true}) {
    final String where = onlyActive ? 'WHERE s.is_active = 1' : '';

    return _db
        .customSelect(
          'SELECT s.*, '
          '  COALESCE(('
          '    SELECT SUM(p.amount_minor) FROM postings p '
          '    WHERE p.account_id = s.advance_account_id AND p.is_voided = 0'
          '  ), 0) AS advance_minor '
          'FROM staff_members s '
          '$where '
          'ORDER BY s.name ASC',
          readsFrom: <TableInfo<Table, Object?>>{
            _db.staffMembers,
            _db.postings,
          },
        )
        .watch()
        .map(
          (List<QueryRow> rows) => rows
              .map(
                (QueryRow row) => StaffWithAccounts(
                  staff: _db.staffMembers.map(row.data),
                  outstandingAdvance: Money(row.read<int>('advance_minor')),
                ),
              )
              .toList(),
        );
  }

  Future<StaffWithAccounts?> staffById(String staffId) async {
    final List<StaffWithAccounts> all =
        await watchStaff(onlyActive: false).first;
    for (final StaffWithAccounts member in all) {
      if (member.id == staffId) return member;
    }
    return null;
  }

  /// Adds someone, creating the two accounts they are tracked through.
  ///
  /// The accounts are made first and in the same call, because a staff member
  /// without them is a row the rest of the code cannot use.
  Future<String> addStaff({
    required String name,
    required Money monthlySalary,
    String? phone,
    DateTime? joinedOn,
  }) async {
    if (name.trim().isEmpty) {
      throw const LedgerValidationError('This person needs a name.');
    }

    final String staffId = Ulid.generate();
    final String salaryAccountId = '$staffAccountPrefix$staffId.salary';
    final String advanceAccountId = '$staffAccountPrefix$staffId.advance';
    final String trimmed = name.trim();

    await applyEvent(
      _localEvent(
        LedgerEventType.accountCreated,
        <String, Object?>{
          'id': salaryAccountId,
          'code': salaryAccountId,
          'name': trimmed,
          'nameUr': trimmed,
          'type': AccountType.expense.index,
          'iconKey': 'staff',
          'colorValue': null,
          'parentId': AccountCodes.idOf(AccountCodes.staff),
          'isSystem': true,
          'sortOrder': 500,
        },
      ),
    );

    await applyEvent(
      _localEvent(
        LedgerEventType.accountCreated,
        <String, Object?>{
          'id': advanceAccountId,
          'code': advanceAccountId,
          'name': '$trimmed — peshgi',
          'nameUr': '$trimmed — پیشگی',
          'type': AccountType.asset.index,
          'iconKey': 'debt',
          'colorValue': null,
          'parentId': null,
          'isSystem': true,
          'sortOrder': 500,
        },
      ),
    );

    await applyEvent(
      _localEvent(
        LedgerEventType.staffSaved,
        <String, Object?>{
          'id': staffId,
          'name': trimmed,
          'phone': phone?.trim(),
          'monthlySalaryMinor': monthlySalary.paisa,
          'salaryAccountId': salaryAccountId,
          'advanceAccountId': advanceAccountId,
          'joinedOn':
              (joinedOn ?? DateTime.now()).millisecondsSinceEpoch,
          'isActive': true,
        },
      ),
    );
    return staffId;
  }

  Future<void> updateStaff({
    required StaffWithAccounts existing,
    required String name,
    required Money monthlySalary,
    String? phone,
  }) {
    return applyEvent(
      _localEvent(
        LedgerEventType.staffSaved,
        <String, Object?>{
          'id': existing.id,
          'name': name.trim(),
          'phone': phone?.trim(),
          'monthlySalaryMinor': monthlySalary.paisa,
          'salaryAccountId': existing.salaryAccountId,
          'advanceAccountId': existing.advanceAccountId,
          'joinedOn': existing.staff.joinedOn.millisecondsSinceEpoch,
          'isActive': true,
        },
      ),
    );
  }

  /// Marks someone as no longer working here.
  ///
  /// Their accounts and every entry against them stay exactly where they are.
  /// A ledger that erases a former employee's history cannot answer what was
  /// paid to them, which is the one thing it is likely to be asked later.
  Future<void> deactivateStaff(String staffId) {
    return applyEvent(
      _localEvent(
        LedgerEventType.staffRemoved,
        <String, Object?>{'id': staffId},
      ),
    );
  }

  // ---- Attendance ----

  Stream<List<StaffAttendanceRow>> watchAttendance({
    required String staffId,
    required DateTime month,
  }) {
    final DateTime first = DateTime(month.year, month.month, 1);
    final DateTime last = DateTime(month.year, month.month, daysInMonth(month));

    final query = _db.select(_db.staffAttendance)
      ..where((StaffAttendance a) => a.staffId.equals(staffId))
      ..where((StaffAttendance a) => a.onDate.isBiggerOrEqualValue(first))
      ..where((StaffAttendance a) => a.onDate.isSmallerOrEqualValue(last))
      ..orderBy(<OrderingTerm Function(StaffAttendance)>[
        (StaffAttendance a) => OrderingTerm.asc(a.onDate),
      ]);
    return query.watch();
  }

  Future<void> markAttendance({
    required String staffId,
    required DateTime date,
    required AttendanceStatus status,
    String? note,
  }) {
    return applyEvent(
      _localEvent(
        LedgerEventType.attendanceMarked,
        <String, Object?>{
          'staffId': staffId,
          'onDate': DraftEntry.dateOnly(date).millisecondsSinceEpoch,
          'status': status.index,
          'note': note,
        },
      ),
    );
  }

  /// Marks every given day at once.
  ///
  /// Most staff are present most days, so the useful gesture is "fill the
  /// month, then fix the handful of exceptions" rather than thirty separate
  /// taps. One event, one transaction.
  Future<void> markAttendanceForDays({
    required String staffId,
    required List<DateTime> days,
    required AttendanceStatus status,
  }) {
    if (days.isEmpty) return Future<void>.value();
    return applyEvent(
      _localEvent(
        LedgerEventType.attendanceRangeMarked,
        <String, Object?>{
          'staffId': staffId,
          'status': status.index,
          'days': <int>[
            for (final DateTime day in days)
              DraftEntry.dateOnly(day).millisecondsSinceEpoch,
          ],
        },
      ),
    );
  }

  /// Removes a mark, returning the day to unrecorded.
  Future<void> clearAttendance({
    required String staffId,
    required DateTime date,
  }) {
    return applyEvent(
      _localEvent(
        LedgerEventType.attendanceCleared,
        <String, Object?>{
          'staffId': staffId,
          'onDate': DraftEntry.dateOnly(date).millisecondsSinceEpoch,
        },
      ),
    );
  }

  /// Works out a month's pay from the register and the outstanding peshgi.
  Future<SalaryCalculation> salaryFor({
    required StaffWithAccounts member,
    required DateTime month,
  }) async {
    final List<StaffAttendanceRow> attendance =
        await watchAttendance(staffId: member.id, month: month).first;

    return SalaryCalculation.compute(
      month: month,
      monthlySalary: member.monthlySalary,
      attendance: attendance,
      outstandingAdvance: await balanceOf(member.advanceAccountId),
    );
  }

  // ---- Money movements ----

  /// Hands over a peshgi.
  ///
  /// Debits the person's advance account and credits cash. Nothing is an
  /// expense yet — the household has not paid for work, it is owed work. That
  /// distinction is what lets the salary entry later settle it on its own
  /// instead of anyone having to remember and subtract.
  Future<String> giveAdvance({
    required StaffWithAccounts member,
    required Money amount,
    required String paidFromAccountId,
    DateTime? on,
  }) {
    if (!amount.isPositive) {
      throw const LedgerValidationError('Enter an amount first.');
    }
    return recordEntry(
      DraftEntry(
        occurredOn: on,
        description: '${member.name} — peshgi',
        postings: <DraftPosting>[
          DraftPosting(accountId: member.advanceAccountId, amount: amount),
          DraftPosting(accountId: paidFromAccountId, amount: -amount),
        ],
      ),
    );
  }

  /// Pays a month's salary, settling any outstanding advance in the same entry.
  ///
  /// Three lines, and they are what make peshgi work without special cases:
  /// the full salary is the expense, the advance account is credited by
  /// whatever it can cover, and only the remainder actually leaves the cash
  /// box. Any advance beyond this month's pay simply stays on the books.
  Future<String> paySalary({
    required StaffWithAccounts member,
    required SalaryCalculation calculation,
    required String paidFromAccountId,
    DateTime? on,
  }) {
    if (!calculation.earned.isPositive) {
      throw const LedgerValidationError('There is nothing to pay this month.');
    }

    final Money settled = calculation.advanceSettled;
    final Money cash = calculation.earned - settled;

    final List<DraftPosting> postings = <DraftPosting>[
      DraftPosting(
        accountId: member.salaryAccountId,
        amount: calculation.earned,
      ),
      if (settled.isPositive)
        DraftPosting(
          accountId: member.advanceAccountId,
          amount: -settled,
        ),
      if (cash.isPositive)
        DraftPosting(accountId: paidFromAccountId, amount: -cash),
    ];

    return recordEntry(
      DraftEntry(
        occurredOn: on,
        description: '${member.name} — salary',
        postings: postings,
      ),
    );
  }

  // ---- Staff event handlers ----

  Future<void> _applyStaffSaved(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    await _db.into(_db.staffMembers).insertOnConflictUpdate(
          StaffMembersCompanion(
            id: Value<String>(payload['id']! as String),
            name: Value<String>(payload['name']! as String),
            phone: Value<String?>(payload['phone'] as String?),
            monthlySalaryMinor:
                Value<int>(payload['monthlySalaryMinor']! as int),
            salaryAccountId:
                Value<String>(payload['salaryAccountId']! as String),
            advanceAccountId:
                Value<String>(payload['advanceAccountId']! as String),
            joinedOn: Value<DateTime>(
              DateTime.fromMillisecondsSinceEpoch(payload['joinedOn']! as int),
            ),
            isActive: Value<bool>((payload['isActive'] as bool?) ?? true),
            createdAtHlc: Value<String>(event.hlc.packed),
            updatedAtHlc: Value<String>(event.hlc.packed),
          ),
        );
  }

  Future<void> _applyStaffRemoved(LedgerEvent event) async {
    await (_db.update(_db.staffMembers)
          ..where((StaffMembers s) =>
              s.id.equals(event.payload['id']! as String)))
        .write(
      StaffMembersCompanion(
        isActive: const Value<bool>(false),
        updatedAtHlc: Value<String>(event.hlc.packed),
      ),
    );
  }

  Future<void> _applyAttendanceMarked(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    final String staffId = payload['staffId']! as String;
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(payload['onDate']! as int);

    // One row per person per day. Marking the same day again corrects it
    // rather than stacking a second record, which is what the unique index on
    // (staff_id, on_date) enforces underneath.
    await (_db.delete(_db.staffAttendance)
          ..where((StaffAttendance a) =>
              a.staffId.equals(staffId) & a.onDate.equals(date)))
        .go();

    await _db.into(_db.staffAttendance).insert(
          StaffAttendanceCompanion.insert(
            id: Ulid.generate(),
            staffId: staffId,
            onDate: date,
            status: AttendanceStatus.values[payload['status']! as int],
            note: Value<String?>(payload['note'] as String?),
            createdAtHlc: event.hlc.packed,
          ),
        );
  }

  Future<void> _applyAttendanceRangeMarked(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    final String staffId = payload['staffId']! as String;
    final AttendanceStatus status =
        AttendanceStatus.values[payload['status']! as int];
    final List<Object?> days = payload['days']! as List<Object?>;

    for (final Object? raw in days) {
      if (raw is! int) continue;
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(raw);

      await (_db.delete(_db.staffAttendance)
            ..where((StaffAttendance a) =>
                a.staffId.equals(staffId) & a.onDate.equals(date)))
          .go();

      await _db.into(_db.staffAttendance).insert(
            StaffAttendanceCompanion.insert(
              id: Ulid.generate(),
              staffId: staffId,
              onDate: date,
              status: status,
              createdAtHlc: event.hlc.packed,
            ),
          );
    }
  }

  Future<void> _applyAttendanceCleared(LedgerEvent event) async {
    final Map<String, Object?> payload = event.payload;
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(payload['onDate']! as int);
    await (_db.delete(_db.staffAttendance)
          ..where((StaffAttendance a) =>
              a.staffId.equals(payload['staffId']! as String) &
              a.onDate.equals(date)))
        .go();
  }

  // ---------------------------------------------------------------------
  // Price memory
  // ---------------------------------------------------------------------

  /// The amounts most recently spent on a category, newest first.
  ///
  /// Feeds the suggestion chips above the keypad. Nearly every household buys
  /// the same things for roughly the same money week after week, so offering
  /// what was paid last time turns typing into tapping — the cheapest kind of
  /// speed, since it needs no prediction, only memory of what the user
  /// themselves already recorded.
  Future<List<Money>> recentAmountsFor(String accountId, {int limit = 4}) async {
    final List<QueryRow> rows = await _db.customSelect(
      'SELECT p.amount_minor AS amount_minor, '
      '       MAX(e.occurred_on) AS last_seen '
      'FROM postings p '
      'JOIN ledger_entries e ON e.id = p.entry_id '
      'WHERE p.account_id = ? AND p.is_voided = 0 AND p.amount_minor > 0 '
      'GROUP BY p.amount_minor '
      'ORDER BY last_seen DESC '
      'LIMIT ?',
      variables: <Variable<Object>>[
        Variable<String>(accountId),
        Variable<int>(limit),
      ],
      readsFrom: <TableInfo<Table, Object?>>{_db.postings, _db.ledgerEntries},
    ).get();

    return rows
        .map((QueryRow row) => Money(row.read<int>('amount_minor')))
        .toList();
  }

  // ---------------------------------------------------------------------
  // Seeding and metadata
  // ---------------------------------------------------------------------

  /// Creates the starting categories if they are missing.
  ///
  /// Safe to call on every launch: seed ids are derived from their slugs and
  /// every insert is an `INSERT OR IGNORE`, so this only ever fills gaps.
  Future<void> ensureSeeded() async {
    final String? seeded = await readMeta(MetaKeys.seededVersion);
    final int seededVersion = int.tryParse(seeded ?? '') ?? 0;
    if (seededVersion >= kSeedVersion) return;

    for (final SeedAccount seed in kSeedAccounts) {
      final AccountRow? existing = await accountById(seed.id);
      if (existing != null) continue;

      await applyEvent(
        _localEvent(
          LedgerEventType.accountCreated,
          <String, Object?>{
            'id': seed.id,
            'code': seed.code,
            'name': seed.name,
            'nameUr': seed.nameUr,
            'type': seed.type.index,
            'iconKey': seed.iconKey,
            'colorValue': null,
            'parentId': seed.parentCode == null
                ? null
                : 'sys.${seed.parentCode}',
            'isSystem': true,
            'sortOrder': seed.sortOrder,
          },
        ),
      );
    }

    await writeMeta(MetaKeys.seededVersion, kSeedVersion.toString());
  }

  Future<String?> readMeta(String key) async {
    final AppMetaRow? row = await (_db.select(_db.appMeta)
          ..where((AppMeta m) => m.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> writeMeta(String key, String value) {
    return _db.into(_db.appMeta).insertOnConflictUpdate(
          AppMetaRow(key: key, value: value),
        );
  }

  Future<void> deleteMeta(String key) {
    return (_db.delete(_db.appMeta)..where((AppMeta m) => m.key.equals(key)))
        .go();
  }
}
