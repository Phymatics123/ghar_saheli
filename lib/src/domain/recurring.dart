import '../core/money.dart';
import '../data/database.dart';

/// Whether a template puts money in or takes it out.
///
/// Stored as the enum index — append only, never reorder.
enum RecurringKind { expense, income }

/// The month a recurring entry belongs to, as `2026-08`.
///
/// Templates are marked confirmed against one of these rather than against a
/// date. That is what stops a bill being recorded twice: once August is
/// stamped on the rent template, rent stops appearing as due until September,
/// no matter how many times the app is opened or the phone's clock moves.
class MonthPeriod {
  MonthPeriod._();

  static String of(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static String current() => of(DateTime.now());
}

/// The last day of the month [date] falls in.
int daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

/// Pins a template's day-of-month to a day that exists in this month.
///
/// Salary on the 31st has to land somewhere in February. Clamping to the last
/// day is what a person does by hand, and it keeps a monthly bill monthly
/// rather than silently skipping the short months.
int clampDayToMonth(int dayOfMonth, DateTime month) {
  final int last = daysInMonth(month);
  return dayOfMonth < 1 ? 1 : (dayOfMonth > last ? last : dayOfMonth);
}

/// A template that is waiting to be confirmed for the current month.
class DueTemplate {
  const DueTemplate({
    required this.template,
    required this.category,
    required this.source,
    required this.dueDate,
  });

  final RecurringTemplateRow template;
  final AccountRow category;
  final AccountRow source;
  final DateTime dueDate;

  String get id => template.id;

  Money get amount => Money(template.amountMinor);

  /// A template with no amount asks for one each time — the electricity bill
  /// is monthly but never the same twice.
  bool get isVariableAmount => template.amountMinor <= 0;

  bool get isExpense => template.kind == RecurringKind.expense;

  int get daysLate {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day).difference(dueDate).inDays;
  }

  bool get isOverdue => daysLate > 0;
}
