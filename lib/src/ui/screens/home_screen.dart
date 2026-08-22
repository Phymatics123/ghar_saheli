import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/database.dart';
import '../../domain/account_type.dart';
import '../../domain/forecast.dart';
import '../../domain/models.dart';
import '../../domain/recurring.dart';
import '../app_scope.dart';
import '../category_icons.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/due_template_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/money_text.dart';
import 'accounts_screen.dart';
import 'add_entry_screen.dart';
import 'settings_screen.dart';

/// The screen the app opens to.
///
/// Answers one question before anything else: how much money is there. That is
/// the number a person opens a household ledger to find, and it sits at the top
/// in the largest type on the screen so it can be read at arm's length without
/// putting anything down.
///
/// Below it, six categories are one tap from the amount keypad. Combined with
/// the entry screen that is two taps and a number to record a purchase — the
/// bar a paper khata sets, and the bar this has to clear to replace one.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const int _quickAddCount = 8;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month, 1);

    // One query feeds both the month totals and the list. The window reaches
    // back past the start of the month so the list is not nearly empty on the
    // first — the totals still count only this month.
    final DateTime windowStart = monthStart.subtract(const Duration(days: 30));

    return Scaffold(
      appBar: AppBar(
        title: Text(s.appName),
        actions: <Widget>[
          // Reachable in one tap on purpose. Its whole use is the moment
          // someone walks over, and a setting three screens deep would be
          // useless for that.
          IconButton(
            icon: Icon(
              AppScope.settingsOf(context).maskAmounts
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            tooltip: s.hideAmounts,
            onPressed: () {
              final AppSettings settings = AppScope.settingsRead(context);
              settings.setMaskAmounts(!settings.maskAmounts);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: s.settings,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<EntryWithPostings>>(
        stream: AppScope.ledgerOf(context)
            .watchEntries(from: windowStart, limit: 200),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<EntryWithPostings>> snapshot,
        ) {
          final List<EntryWithPostings> entries =
              snapshot.data ?? const <EntryWithPostings>[];
          final _MonthTotals totals = _MonthTotals.from(entries, monthStart);

          // Cash on hand is read once here and handed to both the balance card
          // and the forecast, rather than each opening its own stream on the
          // same query.
          return StreamBuilder<Money>(
            stream: AppScope.ledgerOf(context).watchNetCash(),
            builder: (BuildContext context, AsyncSnapshot<Money> cashSnapshot) {
              final Money onHand = cashSnapshot.data ?? Money.zero;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                children: <Widget>[
                  _BalanceCard(totals: totals, onHand: onHand),
                  ForecastCard(
                    forecast: buildForecast(
                      onHand: onHand,
                      spentInWindow: totals.trailingSpent,
                      daysOfData: totals.daysOfData,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _DueTemplates(),
                  const _QuickAddRow(count: _quickAddCount),
                  const SizedBox(height: 20),
                  if (entries.isEmpty)
                    _EmptyState(s: s)
                  else
                    ..._buildGroupedEntries(context, entries),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: const _AddButtons(),
    );
  }

  /// Entries under a heading per day: آج, کل, then dates.
  List<Widget> _buildGroupedEntries(
    BuildContext context,
    List<EntryWithPostings> entries,
  ) {
    final S s = AppScope.stringsOf(context);
    final List<Widget> widgets = <Widget>[];
    DateTime? currentDay;

    for (final EntryWithPostings entry in entries) {
      if (currentDay != entry.occurredOn) {
        currentDay = entry.occurredOn;
        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              top: widgets.isEmpty ? 0 : 18,
              bottom: 6,
              left: 4,
            ),
            child: Text(
              s.dayLabel(entry.occurredOn),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.inkSoft,
                  ),
            ),
          ),
        );
      }
      widgets.add(_EntryRow(entry: entry));
    }
    return widgets;
  }
}

/// Everything the home screen needs folded out of one pass over the entries.
///
/// Two different periods live here on purpose. The month figures are what the
/// card shows, because "spent this month" is the question people ask. The
/// trailing figures are what the forecast runs on, because a month-to-date
/// average is a poor predictor — it restarts at nothing on the 1st and assumes
/// the ledger goes back to the start of the month even when the app was
/// installed halfway through it.
class _MonthTotals {
  const _MonthTotals({
    required this.spent,
    required this.earned,
    required this.trailingSpent,
    required this.daysOfData,
  });

  /// This calendar month, for display.
  final Money spent;
  final Money earned;

  /// The last [SpendForecast.windowDays], for the forecast.
  final Money trailingSpent;

  /// Days actually covered by [trailingSpent] — from the first entry that
  /// recorded any spending to today. Not the size of the window, and not the
  /// day of the month.
  final int daysOfData;

  factory _MonthTotals.from(
    List<EntryWithPostings> entries,
    DateTime monthStart,
  ) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime windowStart =
        today.subtract(const Duration(days: SpendForecast.windowDays));

    int spent = 0;
    int earned = 0;
    int trailing = 0;
    DateTime? firstSpendingDay;

    for (final EntryWithPostings entry in entries) {
      final bool inMonth = !entry.occurredOn.isBefore(monthStart);
      final bool inWindow = !entry.occurredOn.isBefore(windowStart) &&
          !entry.occurredOn.isAfter(today);

      for (final PostingWithAccount line in entry.lines) {
        switch (line.account.type) {
          case AccountType.expense:
            if (!line.amount.isPositive) break;
            if (inMonth) spent += line.amount.paisa;
            if (inWindow) {
              trailing += line.amount.paisa;
              // The span is measured from real spending, so an opening
              // balance recorded today does not count as a day of history.
              if (firstSpendingDay == null ||
                  entry.occurredOn.isBefore(firstSpendingDay)) {
                firstSpendingDay = entry.occurredOn;
              }
            }
          case AccountType.income:
            // Income sits as a credit, so flip it to read as a positive figure.
            if (inMonth && line.amount.isNegative) {
              earned += -line.amount.paisa;
            }
          case AccountType.asset:
          case AccountType.liability:
          case AccountType.equity:
            break;
        }
      }
    }

    // Inclusive of both ends: spending on one day is one day of data.
    final int days = firstSpendingDay == null
        ? 0
        : today.difference(firstSpendingDay).inDays + 1;

    return _MonthTotals(
      spent: Money(spent),
      earned: Money(earned),
      trailingSpent: Money(trailing),
      daysOfData: days,
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.totals, required this.onHand});

  final _MonthTotals totals;
  final Money onHand;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        // The obvious thing to do when you look at a total is ask what it is
        // made of, so the total itself is the way in.
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AccountsScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppTheme.primary, AppTheme.primaryDark],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Which month everything below refers to. Without it the
              // figures are just numbers with no period attached.
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${s.monthName(DateTime.now().month)} '
                      '${DateTime.now().year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  // Income rides up here rather than taking a column of its
                  // own. It is checked far less often than spending, but a
                  // ledger that only counts what leaves is half a ledger.
                  if (totals.earned.isPositive) ...<Widget>[
                    Text(
                      '${s.income}  ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 11,
                      ),
                    ),
                    MoneyText(
                      totals.earned,
                      symbol: false,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                s.moneyInHand,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              MoneyText(
                onHand,
                style:
                    theme.textTheme.displayLarge?.copyWith(color: Colors.white),
              ),

              const SizedBox(height: 14),
              Divider(
                color: Colors.white.withValues(alpha: 0.22),
                height: 1,
              ),
              const SizedBox(height: 12),

              // Two columns, split down the middle: where the money sits, and
              // where this month's spending went out of. Same shape on both
              // sides — a label, then rows of account and amount — so the eye
              // reads them the same way.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _CardColumn(
                        label: s.whereItIs,
                        stream: AppScope.ledgerOf(context)
                            .watchAccountBalances(type: AccountType.asset),
                        emptyLabel: null,
                      ),
                    ),
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    Expanded(
                      child: _CardColumn(
                        label: s.spentThisMonth,
                        headline: totals.spent,
                        stream: AppScope.ledgerOf(context)
                            .watchSpendingBySource(
                          from: DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            1,
                          ),
                          to: DateTime.now(),
                        ),
                        emptyLabel: '—',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One half of the balance card: a heading, an optional headline figure, then
/// a short list of account-and-amount rows.
class _CardColumn extends StatelessWidget {
  const _CardColumn({
    required this.label,
    required this.stream,
    required this.emptyLabel,
    this.headline,
  });

  final String label;
  final Stream<List<AccountBalance>> stream;
  final Money? headline;

  /// Shown when there is nothing to list. Null hides the row entirely.
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    final TextStyle? labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white.withValues(alpha: 0.72),
      fontSize: 11,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: labelStyle, maxLines: 1),
        if (headline != null) ...<Widget>[
          const SizedBox(height: 1),
          MoneyText(
            headline!,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ],
        const SizedBox(height: 6),
        StreamBuilder<List<AccountBalance>>(
          stream: stream,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<AccountBalance>> snapshot,
          ) {
            final List<AccountBalance> rows =
                snapshot.data ?? const <AccountBalance>[];
            if (rows.isEmpty) {
              return emptyLabel == null
                  ? const SizedBox.shrink()
                  : Text(emptyLabel!, style: labelStyle);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Three is what fits without the card growing taller than the
                // thing it sits above.
                for (final AccountBalance row in rows.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          iconForKey(row.account.iconKey),
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            s.accountName(row.account),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: labelStyle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        MoneyText(
                          row.displayBalance,
                          symbol: false,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}


/// Bills that are due and not yet recorded, above everything else.
///
/// Empty for most of the month, which is the point — it only takes up room on
/// the days it has something to say.
class _DueTemplates extends StatelessWidget {
  const _DueTemplates();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DueTemplate>>(
      stream: AppScope.ledgerOf(context).watchDueTemplates(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<DueTemplate>> snapshot,
      ) {
        final List<DueTemplate> due = snapshot.data ?? const <DueTemplate>[];
        if (due.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: <Widget>[
              for (final DueTemplate template in due)
                DueTemplateCard(
                  due: template,
                  onConfirm: () => _confirm(context, template),
                ),
            ],
          ),
        );
      },
    );
  }

  /// A fixed-amount bill is one tap. One whose amount changes every month —
  /// electricity, gas — opens the keypad with the category already chosen,
  /// because the app has no way of knowing this month's figure.
  Future<void> _confirm(BuildContext context, DueTemplate due) async {
    final S s = AppScope.stringsOf(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ledger = AppScope.ledgerRead(context);

    if (due.isVariableAmount) {
      await openAddEntry(
        context,
        kind: due.isExpense ? EntryKind.expense : EntryKind.income,
        preselected: due.category,
        confirmingTemplate: due,
      );
      return;
    }

    await ledger.confirmTemplate(due: due);
    messenger.showSnackBar(SnackBar(content: Text(s.saved)));
  }
}

/// The categories a household reaches for daily, one tap from the keypad.
class _QuickAddRow extends StatelessWidget {
  const _QuickAddRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AccountBalance>>(
      stream: AppScope.ledgerOf(context)
          .watchAccountBalances(type: AccountType.expense),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<AccountBalance>> snapshot,
      ) {
        final List<AccountBalance> all =
            snapshot.data ?? const <AccountBalance>[];
        if (all.isEmpty) return const SizedBox.shrink();

        // Four across, two rows. Six across leaves roughly 60dp per tile on a
        // 360dp phone, which truncates "بجلی کا بل" to something unreadable —
        // and an unreadable label defeats the point of a shortcut.
        final List<AccountBalance> shown = all.take(count).toList();
        return Column(
          children: <Widget>[
            for (int start = 0; start < shown.length; start += 4)
              Row(
                children: <Widget>[
                  for (int i = start; i < start + 4; i++)
                    Expanded(
                      child: i < shown.length
                          ? _QuickTile(account: shown[i].account)
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.account});

  final AccountRow account;

  @override
  Widget build(BuildContext context) {
    final Color accent = colorForIcon(account.iconKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => openAddEntry(
          context,
          kind: EntryKind.expense,
          preselected: account,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconForKey(account.iconKey),
                    color: accent, size: 24),
              ),
              const SizedBox(height: 5),
              Text(
                AppScope.stringsOf(context).accountName(account),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final EntryWithPostings entry;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final PostingWithAccount? primary = entry.primaryLine;
    final AccountRow? account = primary?.account;
    final bool isIncome = account?.type == AccountType.income;
    final Color accent = colorForIcon(account?.iconKey);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: accent.withValues(alpha: 0.14),
          child: Icon(iconForKey(account?.iconKey), color: accent, size: 22),
        ),
        title: Text(
          account == null ? entry.entry.description : s.accountName(account),
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: entry.entry.note == null
            ? null
            : Text(entry.entry.note!,
                maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: MoneyText(
          entry.magnitude,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isIncome ? AppTheme.earn : AppTheme.spend,
              ),
        ),
        onTap: () => _confirmRemove(context, s),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, S s) async {
    final ledger = AppScope.ledgerRead(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool? remove = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MoneyText(
                  entry.magnitude,
                  style: Theme.of(sheetContext).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  s.dayLabel(entry.occurredOn),
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(s.remove),
                  style: FilledButton.styleFrom(
                    foregroundColor: AppTheme.spend,
                    backgroundColor: AppTheme.spend.withValues(alpha: 0.10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (remove != true) return;
    await ledger.voidEntry(entry.id);
    messenger.showSnackBar(SnackBar(content: Text(s.removed)));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.s});

  final S s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: <Widget>[
          const Icon(Icons.receipt_long_outlined,
              size: 56, color: AppTheme.inkSoft),
          const SizedBox(height: 14),
          Text(s.nothingYet, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            s.startByAdding,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AddButtons extends StatelessWidget {
  const _AddButtons();

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        // Income is rarer than spending, so it gets the smaller button — but
        // it stays on the main screen rather than hiding in a menu, because
        // a ledger that only counts what leaves is only half a ledger.
        FloatingActionButton.small(
          heroTag: 'income',
          backgroundColor: AppTheme.earn,
          foregroundColor: Colors.white,
          tooltip: s.addIncome,
          onPressed: () => openAddEntry(context, kind: EntryKind.income),
          child: const Icon(Icons.south_west),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.large(
          heroTag: 'expense',
          backgroundColor: AppTheme.spend,
          foregroundColor: Colors.white,
          tooltip: s.addExpense,
          onPressed: () => openAddEntry(context, kind: EntryKind.expense),
          child: const Icon(Icons.add, size: 36),
        ),
      ],
    );
  }
}

/// Opens the entry flow and reports back when something was recorded.
Future<void> openAddEntry(
  BuildContext context, {
  required EntryKind kind,
  AccountRow? preselected,
  DueTemplate? confirmingTemplate,
}) async {
  final S s = AppScope.stringsOf(context);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

  final bool? saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => AddEntryScreen(
        kind: kind,
        preselected: preselected,
        confirmingTemplate: confirmingTemplate,
      ),
    ),
  );

  if (saved == true) {
    messenger.showSnackBar(SnackBar(content: Text(s.saved)));
  }
}
