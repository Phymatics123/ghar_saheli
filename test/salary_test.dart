import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_saheli/src/core/money.dart';
import 'package:ghar_saheli/src/data/database.dart';
import 'package:ghar_saheli/src/domain/staff.dart';

/// Salary and peshgi arithmetic.
///
/// This is the calculation most worth being certain about in the whole app.
/// It decides what a domestic worker is handed at the end of a month, and an
/// error here is not a display glitch — it is someone being underpaid.
void main() {
  // April: 30 days, so a Rs 15,000 salary is exactly Rs 500 a day and the
  // expected figures below are checkable by hand.
  final DateTime april = DateTime(2026, 4, 1);
  const Money salary = Money(1500000); // Rs 15,000

  StaffAttendanceRow day(int dayOfMonth, AttendanceStatus status) {
    return StaffAttendanceRow(
      id: 'a$dayOfMonth',
      staffId: 'staff-1',
      onDate: DateTime(2026, 4, dayOfMonth),
      status: status,
      createdAtHlc: '0',
    );
  }

  group('SalaryCalculation', () {
    test('an unmarked month pays in full', () {
      // Nothing in the register at all. The household simply did not fill it
      // in, and that is not evidence anyone stayed home.
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: const <StaffAttendanceRow>[],
        outstandingAdvance: Money.zero,
      );

      expect(result.unmarkedDays, 30);
      expect(result.deduction, Money.zero);
      expect(result.earned, salary);
      expect(result.netPayable, salary);
    });

    test('a day rate is the salary divided by the days in that month', () {
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: const <StaffAttendanceRow>[],
        outstandingAdvance: Money.zero,
      );
      expect(result.daysInMonth, 30);
      expect(result.dailyRate, Money.rupees(500));
    });

    test('absences are deducted at the day rate', () {
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: <StaffAttendanceRow>[
          day(3, AttendanceStatus.absent),
          day(4, AttendanceStatus.absent),
        ],
        outstandingAdvance: Money.zero,
      );
      expect(result.absentDays, 2);
      expect(result.deduction, Money.rupees(1000));
      expect(result.earned, Money.rupees(14000));
    });

    test('a half day costs half a day', () {
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: <StaffAttendanceRow>[day(5, AttendanceStatus.halfDay)],
        outstandingAdvance: Money.zero,
      );
      expect(result.deduction, Money.rupees(250));
      expect(result.earned, Money.rupees(14750));
    });

    test('agreed leave is paid and deducts nothing', () {
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: <StaffAttendanceRow>[
          day(6, AttendanceStatus.leave),
          day(7, AttendanceStatus.leave),
        ],
        outstandingAdvance: Money.zero,
      );
      expect(result.leaveDays, 2);
      expect(result.deduction, Money.zero);
      expect(result.earned, salary);
    });

    test('marking someone present changes nothing, as it should', () {
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: <StaffAttendanceRow>[
          for (int d = 1; d <= 30; d++) day(d, AttendanceStatus.present),
        ],
        outstandingAdvance: Money.zero,
      );
      expect(result.presentDays, 30);
      expect(result.unmarkedDays, 0);
      expect(result.earned, salary);
    });

    test('an advance is settled out of the month pay', () {
      // Rs 5,000 peshgi taken mid-month against a Rs 15,000 salary.
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: const <StaffAttendanceRow>[],
        outstandingAdvance: Money.rupees(5000),
      );
      expect(result.advanceSettled, Money.rupees(5000));
      expect(result.netPayable, Money.rupees(10000));
      expect(result.carriesForward, isFalse);
    });

    test('an advance larger than the pay carries forward, never goes negative',
        () {
      // Rs 20,000 taken against a Rs 15,000 month. Nothing changes hands and
      // Rs 5,000 is still owed — it is not written off, and the worker is not
      // asked to hand money back.
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: const <StaffAttendanceRow>[],
        outstandingAdvance: Money.rupees(20000),
      );
      expect(result.advanceSettled, Money.rupees(15000));
      expect(result.carriesForward, isTrue);
      expect(result.carriedForward, Money.rupees(5000));
      expect(result.earned - result.advanceSettled, Money.zero);
    });

    test('absences and an advance combine correctly', () {
      // Three days missed and Rs 3,000 already taken.
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: <StaffAttendanceRow>[
          day(2, AttendanceStatus.absent),
          day(3, AttendanceStatus.absent),
          day(4, AttendanceStatus.absent),
        ],
        outstandingAdvance: Money.rupees(3000),
      );
      expect(result.deduction, Money.rupees(1500));
      expect(result.earned, Money.rupees(13500));
      expect(result.netPayable, Money.rupees(10500));
    });

    test('earnings never go below zero however many days are missed', () {
      final SalaryCalculation result = SalaryCalculation.compute(
        month: april,
        monthlySalary: salary,
        attendance: <StaffAttendanceRow>[
          for (int d = 1; d <= 30; d++) day(d, AttendanceStatus.absent),
        ],
        outstandingAdvance: Money.zero,
      );
      expect(result.earned, Money.zero);
      expect(result.earned.isNegative, isFalse);
    });

    test('a short month has a higher day rate than a long one', () {
      final SalaryCalculation february = SalaryCalculation.compute(
        month: DateTime(2026, 2, 1),
        monthlySalary: salary,
        attendance: const <StaffAttendanceRow>[],
        outstandingAdvance: Money.zero,
      );
      final SalaryCalculation august = SalaryCalculation.compute(
        month: DateTime(2026, 8, 1),
        monthlySalary: salary,
        attendance: const <StaffAttendanceRow>[],
        outstandingAdvance: Money.zero,
      );
      expect(february.daysInMonth, 28);
      expect(august.daysInMonth, 31);
      expect(february.dailyRate > august.dailyRate, isTrue);
      // Whatever the month, an untouched register still pays the full salary.
      expect(february.earned, salary);
      expect(august.earned, salary);
    });
  });
}
