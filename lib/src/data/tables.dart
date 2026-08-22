import 'package:drift/drift.dart';

import '../domain/account_type.dart';
import '../domain/recurring.dart';
import '../domain/staff.dart';

/// Categories and money-holders. Groceries, Cash in Hand, a maid's advance.
@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text()();

  /// Stable slug such as `expense.groceries`. Seeded accounts derive their id
  /// from this, so two phones in the same household independently create the
  /// *same* id for "Groceries" and never end up with duplicate categories
  /// once they sync.
  TextColumn get code => text().unique()();

  TextColumn get name => text()();
  TextColumn get nameUr => text()();
  IntColumn get type => intEnum<AccountType>()();

  TextColumn get parentId =>
      text().nullable().references(Accounts, #id)();

  /// Icon name resolved by the UI layer. Kept as a string so the data layer
  /// never imports Flutter and stays testable without a device.
  TextColumn get iconKey => text().nullable()();
  IntColumn get colorValue => integer().nullable()();

  /// Seeded accounts cannot be deleted, only hidden. Deleting one would orphan
  /// history the user still needs to read.
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  TextColumn get createdAtHlc => text()();
  TextColumn get updatedAtHlc => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// One journal entry — "bought vegetables", "paid Nasreen's salary".
///
/// Named `LedgerEntries` rather than `Transactions` because drift already owns
/// the word `Transaction` for database transactions.
@DataClassName('LedgerEntryRow')
class LedgerEntries extends Table {
  TextColumn get id => text()();

  /// The day the money actually moved, normalised to local midnight. Distinct
  /// from when the row was typed in — people enter yesterday's shopping today.
  DateTimeColumn get occurredOn => dateTime()();

  TextColumn get description => text()();
  TextColumn get note => text().nullable()();

  /// Entries are never deleted, only voided.
  ///
  /// A ledger that can lose rows is a ledger that can silently disagree with
  /// itself after a sync, and a household arguing about a maid's salary needs
  /// the original record to still exist. Voiding is itself an event.
  BoolColumn get isVoided => boolean().withDefault(const Constant(false))();
  TextColumn get voidedByEventId => text().nullable()();

  TextColumn get createdAtHlc => text()();
  TextColumn get deviceId => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The debit and credit lines of an entry. Every entry's postings sum to zero.
@DataClassName('PostingRow')
class Postings extends Table {
  TextColumn get id => text()();

  TextColumn get entryId => text().references(LedgerEntries, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();

  /// Signed, in paisa. Positive is a debit, negative is a credit.
  IntColumn get amountMinor => integer()();

  TextColumn get memo => text().nullable()();

  /// Order of the lines inside one entry, so a receipt reads back the way it
  /// was written.
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// Mirrors `LedgerEntries.isVoided`, maintained in the same transaction.
  ///
  /// Denormalised on purpose: balances are the hottest query in the app and
  /// this turns a three-table join into a two-table one. On a 4GB budget
  /// phone that difference is felt.
  BoolColumn get isVoided => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The append-only log. See `LedgerEvent`.
@DataClassName('LedgerEventRow')
class LedgerEvents extends Table {
  TextColumn get id => text()();

  /// Packed HLC, fixed width so a plain TEXT index sorts causally.
  TextColumn get hlc => text()();

  TextColumn get deviceId => text()();
  IntColumn get type => integer()();
  TextColumn get payload => text()();

  /// When this device applied the event — not when it was created. For a
  /// remote event these differ, and that gap is what a sync log needs to show.
  DateTimeColumn get appliedAt => dateTime()();

  BoolColumn get isRemote => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A bill or payment that comes round every month.
///
/// Rent, the electricity bill, a maid's salary, school fees. The household
/// already knows these are coming; the app's job is to stop them being typed
/// out from scratch twelve times a year and to notice when one has not been
/// recorded yet.
///
/// Templates are settings, not ledger history — nothing here is an entry until
/// the user confirms one, at which point a normal double-entry lands in the
/// ledger like any other.
@DataClassName('RecurringTemplateRow')
class RecurringTemplates extends Table {
  TextColumn get id => text()();

  IntColumn get kind => intEnum<RecurringKind>()();

  /// The category being spent on, or the source money arrives from.
  ///
  /// Both this and [sourceAccountId] point at `accounts`, so each needs an
  /// explicit reverse name — otherwise drift cannot tell the two apart when it
  /// generates the back-references and warns on every build.
  @ReferenceName('templatesByCategory')
  TextColumn get categoryAccountId => text().references(Accounts, #id)();

  /// The pocket it is paid from, or received into.
  @ReferenceName('templatesBySource')
  TextColumn get sourceAccountId => text().references(Accounts, #id)();

  /// Zero means the amount changes every month and should be asked for.
  /// A bijli bill is never the same twice; rent usually is.
  IntColumn get amountMinor => integer().withDefault(const Constant(0))();

  TextColumn get description => text()();

  /// Day of the month it falls due, 1–31. Clamped at read time for months that
  /// are too short — see `clampDayToMonth`.
  IntColumn get dayOfMonth => integer()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// The last month stamped as done, as `2026-08`. Null until first confirmed.
  ///
  /// This is the whole duplicate-protection mechanism: a template whose stamp
  /// matches the current month is not due, however many times the app opens.
  TextColumn get lastPostedPeriod => text().nullable()();

  TextColumn get createdAtHlc => text()();
  TextColumn get updatedAtHlc => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A person who works in the house — a maid, a cook, a driver.
///
/// Each one owns two ledger accounts, created with them and never shown in the
/// ordinary category pickers. Their codes start with `staff.`, which is how
/// they are filtered out.
@DataClassName('StaffMemberRow')
class StaffMembers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// For sending a salary receipt over WhatsApp. Optional — plenty of
  /// arrangements are entirely in person.
  TextColumn get phone => text().nullable()();

  IntColumn get monthlySalaryMinor => integer()();

  /// Expense account. Everything paid to this person accumulates here.
  ///
  /// Named explicitly for the same reason as the template columns: two
  /// foreign keys into `accounts` leave drift unable to name the reverse
  /// lookups on its own.
  @ReferenceName('staffBySalaryAccount')
  TextColumn get salaryAccountId => text().references(Accounts, #id)();

  /// Asset account. Peshgi sits here until a salary settles it.
  @ReferenceName('staffByAdvanceAccount')
  TextColumn get advanceAccountId => text().references(Accounts, #id)();

  DateTimeColumn get joinedOn => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  TextColumn get createdAtHlc => text()();
  TextColumn get updatedAtHlc => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// One day in the attendance register.
///
/// Kept apart from the ledger on purpose. Attendance is a record of who turned
/// up; it becomes money only when a salary is worked out from it, and the
/// household should be able to correct a day in the register without that
/// touching the books.
@DataClassName('StaffAttendanceRow')
class StaffAttendance extends Table {
  TextColumn get id => text()();

  @ReferenceName('attendanceByStaff')
  TextColumn get staffId => text().references(StaffMembers, #id)();

  /// Normalised to local midnight, so one day has exactly one row.
  DateTimeColumn get onDate => dateTime()();

  IntColumn get status => intEnum<AttendanceStatus>()();
  TextColumn get note => text().nullable()();

  TextColumn get createdAtHlc => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Small key/value store for device identity, clock state and settings.
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
