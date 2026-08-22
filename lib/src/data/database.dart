import 'package:drift/drift.dart';

// Imported for the generated part file rather than for this file. `database.g
// .dart` is a `part of` this library, and a part can only resolve names the
// parent file imports — imports do not travel through `tables.dart`.
import '../domain/account_type.dart';
import '../domain/recurring.dart';
import '../domain/staff.dart';
import 'tables.dart';

// Callers that hold an [AppDatabase] also need the table classes to write
// typed `where` clauses against it, so they travel together.
export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: <Type>[
    Accounts,
    LedgerEntries,
    Postings,
    LedgerEvents,
    RecurringTemplates,
    StaffMembers,
    StaffAttendance,
    AppMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// 1 — the Stage 0 ledger.
  /// 2 — adds recurring templates.
  /// 3 — adds staff members and their attendance register.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
        },

        // Runs on a phone that already holds a ledger. It only ever adds; no
        // step here rewrites or drops anything that existed before, because a
        // migration that loses a user's history is not a bug you can apologise
        // your way out of.
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(recurringTemplates);
            await customStatement(_dueTemplatesIndex);
          }
          if (from < 3) {
            await m.createTable(staffMembers);
            await m.createTable(staffAttendance);
            for (final String sql in _staffIndexes) {
              await customStatement(sql);
            }
          }
        },

        beforeOpen: (OpeningDetails details) async {
          // Off by default in SQLite. Without it the `references` declarations
          // in tables.dart are documentation rather than a guarantee.
          await customStatement('PRAGMA foreign_keys = ON');

          // Survives the app being killed mid-write far better than the
          // default rollback journal, and lets reads continue during a write.
          await customStatement('PRAGMA journal_mode = WAL');

          // Durable enough for a ledger, without an fsync on every statement.
          await customStatement('PRAGMA synchronous = NORMAL');
        },
      );

  /// Indexes are written by hand rather than via annotations so the exact SQL
  /// is visible and reviewable — these are the queries the whole app leans on.
  Future<void> _createIndexes() async {
    const List<String> statements = <String>[
      // Balance of an account = sum of its live postings. Hottest query here.
      'CREATE INDEX IF NOT EXISTS idx_postings_account_live '
          'ON postings (account_id, is_voided)',
      // Reading back one entry's lines.
      'CREATE INDEX IF NOT EXISTS idx_postings_entry '
          'ON postings (entry_id)',
      // "This month" lists and summaries.
      'CREATE INDEX IF NOT EXISTS idx_entries_occurred '
          'ON ledger_entries (occurred_on)',
      // Replaying or shipping the log in causal order.
      'CREATE INDEX IF NOT EXISTS idx_events_hlc '
          'ON ledger_events (hlc)',
      // Category pickers, which always hide archived rows.
      'CREATE INDEX IF NOT EXISTS idx_accounts_type_live '
          'ON accounts (type, is_archived)',
      // Which bills are still waiting to be confirmed this month.
      _dueTemplatesIndex,
      ..._staffIndexes,
    ];
    for (final String sql in statements) {
      await customStatement(sql);
    }
  }

  static const List<String> _staffIndexes = <String>[
    'CREATE INDEX IF NOT EXISTS idx_staff_active '
        'ON staff_members (is_active)',
    // Reading a month's register, and the unique constraint that keeps one
    // row per person per day so marking a day twice corrects it rather than
    // duplicating it.
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_attendance_staff_day '
        'ON staff_attendance (staff_id, on_date)',
  ];

  /// Shared between a fresh install and the v1 upgrade, so the two paths can
  /// never end up with a different set of indexes.
  static const String _dueTemplatesIndex =
      'CREATE INDEX IF NOT EXISTS idx_templates_active '
      'ON recurring_templates (is_active, day_of_month)';
}
