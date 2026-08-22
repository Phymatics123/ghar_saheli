import '../core/money.dart';
import '../data/database.dart';
// Prefixed: this file has a `daysInMonth` field, which would otherwise shadow
// the helper of the same name and resolve to an int rather than a function.
import 'recurring.dart' as calendar;

/// How a day was worked.
///
/// Stored as the enum index — append only, never reorder.
enum AttendanceStatus {
  present,

  /// Not there, and not a paid day.
  absent,

  /// Came for part of the day. Counts as half a day's pay.
  halfDay,

  /// Agreed leave. Paid, so it does not reduce the salary.
  leave,
}

extension AttendanceStatusMath on AttendanceStatus {
  /// Halves of a day *not* worked, so integer arithmetic stays exact.
  int get unpaidHalves => switch (this) {
        AttendanceStatus.present => 0,
        AttendanceStatus.leave => 0,
        AttendanceStatus.halfDay => 1,
        AttendanceStatus.absent => 2,
      };
}

/// A staff member with the two accounts the ledger tracks them through.
class StaffWithAccounts {
  const StaffWithAccounts({
    required this.staff,
    required this.outstandingAdvance,
  });

  final StaffMemberRow staff;

  /// Peshgi taken and not yet worked off. Zero when nothing is outstanding.
  final Money outstandingAdvance;

  String get id => staff.id;
  String get name => staff.name;
  Money get monthlySalary => Money(staff.monthlySalaryMinor);

  /// Expense account. Everything ever paid to this person lands here, which is
  /// what makes "how much have I paid Nasreen this year" a question with an
  /// answer.
  ///
  /// Held as an id rather than a joined row: nothing ever read the account's
  /// name or icon, so joining two aliased copies of `accounts` on every query
  /// was work for a value nobody used.
  String get salaryAccountId => staff.salaryAccountId;

  /// Asset account. An advance is money the household is owed back in work,
  /// so it sits on the asset side until the salary settles it.
  String get advanceAccountId => staff.advanceAccountId;
}

/// What a staff member is owed for one month, and how that number was reached.
///
/// Peshgi is the reason this app exists in the form it does. The arrangement is
/// entirely verbal in most households — an advance is handed over mid-month,
/// remembered by both sides, and argued about on payday. Double-entry settles
/// it without anyone having to trust their memory: the advance sits as an asset
/// until the salary posts, and the salary entry clears it automatically.
///
/// Nothing here is ever applied silently. The figures are shown, and the user
/// confirms them, because a wrong deduction from a domestic worker's pay is not
/// an error the app should be able to make on its own.
class SalaryCalculation {
  const SalaryCalculation({
    required this.month,
    required this.monthlySalary,
    required this.daysInMonth,
    required this.presentDays,
    required this.absentDays,
    required this.halfDays,
    required this.leaveDays,
    required this.unmarkedDays,
    required this.dailyRate,
    required this.deduction,
    required this.earned,
    required this.outstandingAdvance,
  });

  final DateTime month;
  final Money monthlySalary;
  final int daysInMonth;
  final int presentDays;
  final int absentDays;
  final int halfDays;
  final int leaveDays;

  /// Days with no attendance recorded at all.
  ///
  /// Treated as worked rather than absent. Silence in a register is not
  /// evidence someone did not turn up, and defaulting the other way would
  /// quietly dock pay for the household's own failure to mark the book.
  final int unmarkedDays;

  final Money dailyRate;
  final Money deduction;

  /// Salary less deductions, before any advance is settled.
  final Money earned;

  final Money outstandingAdvance;

  /// What actually changes hands. Negative when the advance was larger than
  /// the month's pay — the remainder carries forward rather than being
  /// written off.
  Money get netPayable => earned - outstandingAdvance;

  bool get carriesForward => netPayable.isNegative;

  Money get carriedForward =>
      carriesForward ? netPayable.abs : Money.zero;

  /// The part of the advance this month's pay can actually cover.
  Money get advanceSettled =>
      outstandingAdvance > earned ? earned : outstandingAdvance;

  static SalaryCalculation compute({
    required DateTime month,
    required Money monthlySalary,
    required List<StaffAttendanceRow> attendance,
    required Money outstandingAdvance,
  }) {
    final int totalDays = calendar.daysInMonth(month);

    int present = 0;
    int absent = 0;
    int half = 0;
    int leave = 0;
    int unpaidHalves = 0;

    for (final StaffAttendanceRow day in attendance) {
      switch (day.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.halfDay:
          half++;
        case AttendanceStatus.leave:
          leave++;
      }
      unpaidHalves += day.status.unpaidHalves;
    }

    final int marked = present + absent + half + leave;
    final int unmarked = totalDays - marked < 0 ? 0 : totalDays - marked;

    // Rate per day, then per half-day, so a half day is never off by a paisa.
    final Money dailyRate = Money(monthlySalary.paisa ~/ totalDays);
    final Money deduction =
        Money((dailyRate.paisa * unpaidHalves) ~/ 2);

    Money earned = monthlySalary - deduction;
    if (earned.isNegative) earned = Money.zero;

    return SalaryCalculation(
      month: month,
      monthlySalary: monthlySalary,
      daysInMonth: totalDays,
      presentDays: present,
      absentDays: absent,
      halfDays: half,
      leaveDays: leave,
      unmarkedDays: unmarked,
      dailyRate: dailyRate,
      deduction: deduction,
      earned: earned,
      outstandingAdvance: outstandingAdvance,
    );
  }
}
