import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_saheli/src/core/money.dart';
import 'package:ghar_saheli/src/domain/forecast.dart';
import 'package:ghar_saheli/src/domain/recurring.dart';

/// The forecast is the one piece of arithmetic in this app that tells a user
/// something about their future rather than their past, so it is also the one
/// most worth being sure about. All pure logic — no database, no device.
void main() {
  group('SpendForecast', () {
    test('says nothing until there are a few days of real data', () {
      // Four days in, one big raashan shop. A flat average here would claim
      // the money runs out almost immediately, which is alarming and wrong.
      final SpendForecast forecast = SpendForecast.compute(
        onHand: Money.rupees(40000),
        spentInWindow: Money.rupees(20000),
        daysOfData: 4,
        asOf: DateTime(2026, 8, 20),
      );
      expect(forecast.status, ForecastStatus.notEnoughData);
      expect(forecast.isWorthShowing, isFalse);
    });

    test('says nothing when nothing has been spent', () {
      final SpendForecast forecast = SpendForecast.compute(
        onHand: Money.rupees(40000),
        spentInWindow: Money.zero,
        daysOfData: 20,
        asOf: DateTime(2026, 8, 20),
      );
      expect(forecast.status, ForecastStatus.notEnoughData);
    });

    test('divides by days observed, not by the day of the month', () {
      // The regression this whole rewrite exists for. Someone installs on the
      // 14th and records six days of spending: Rs 12,000 over six days is
      // Rs 2,000 a day, and Rs 10,000 left lasts five more.
      //
      // Dividing by the calendar day instead — as it once did — would have
      // called it Rs 600 a day and promised sixteen days, because it assumed
      // the ledger went back to the 1st when it did not.
      final SpendForecast forecast = SpendForecast.compute(
        onHand: Money.rupees(10000),
        spentInWindow: Money.rupees(12000),
        daysOfData: 6,
        asOf: DateTime(2026, 8, 20),
      );

      expect(forecast.dailyBurn, Money.rupees(2000));
      expect(forecast.daysUntilEmpty, 5);
      expect(forecast.status, ForecastStatus.willRunOut);

      // The old, wrong answer.
      expect(forecast.dailyBurn, isNot(Money.rupees(600)));
    });

    test('the rate does not lurch when a new month starts', () {
      // A month-to-date average restarts from a single day on the 1st, so the
      // same household with the same habits saw the estimate jump overnight.
      // A trailing window carries straight across.
      SpendForecast on(DateTime date) => SpendForecast.compute(
            onHand: Money.rupees(20000),
            spentInWindow: Money.rupees(10000),
            daysOfData: 10,
            asOf: date,
          );

      expect(
        on(DateTime(2026, 8, 31)).dailyBurn,
        on(DateTime(2026, 9, 1)).dailyBurn,
      );
    });

    test('averages over at most the window, however long the history', () {
      // Two years of history still answers "what is the rate lately".
      final SpendForecast forecast = SpendForecast.compute(
        onHand: Money.rupees(50000),
        spentInWindow: Money.rupees(30000),
        daysOfData: 700,
        asOf: DateTime(2026, 8, 20),
      );
      expect(forecast.dailyBurn, Money.rupees(1000));
    });

    test('warns when the money runs out before the month does', () {
      // Rs 2,000 a day, Rs 15,000 left: seven more days, against eleven left
      // in August.
      final SpendForecast forecast = SpendForecast.compute(
        onHand: Money.rupees(15000),
        spentInWindow: Money.rupees(20000),
        daysOfData: 10,
        asOf: DateTime(2026, 8, 20),
      );
      expect(forecast.status, ForecastStatus.willRunOut);
      expect(forecast.daysUntilEmpty, 7);
      expect(forecast.daysLeftInMonth, 11);
    });

    test('is comfortable when the money outlasts the month with room', () {
      final SpendForecast forecast = SpendForecast.compute(
        onHand: Money.rupees(90000),
        spentInWindow: Money.rupees(10000),
        daysOfData: 10,
        asOf: DateTime(2026, 8, 10),
      );
      expect(forecast.status, ForecastStatus.comfortable);
      expect(forecast.daysUntilEmpty, 90);
    });

    test('is tight when it only just reaches month end', () {
      // Rs 2,000 a day and Rs 24,000 left is twelve days, against eleven
      // remaining — over the line, but not by much.
      final SpendForecast forecast = SpendForecast.compute(
        onHand: Money.rupees(24000),
        spentInWindow: Money.rupees(40000),
        daysOfData: 20,
        asOf: DateTime(2026, 8, 20),
      );
      expect(forecast.status, ForecastStatus.tight);
      expect(forecast.daysUntilEmpty, 12);
      expect(forecast.daysLeftInMonth, 11);
    });

    test('reports empty when there is nothing left, whatever the date', () {
      final SpendForecast forecast = SpendForecast.compute(
        onHand: Money.zero,
        spentInWindow: Money.rupees(50000),
        daysOfData: 15,
        asOf: DateTime(2026, 8, 15),
      );
      expect(forecast.status, ForecastStatus.empty);
      expect(forecast.isWorthShowing, isTrue);
    });

    test('treats an overdrawn balance as empty rather than negative days', () {
      final SpendForecast forecast = SpendForecast.compute(
        onHand: Money.rupees(-500),
        spentInWindow: Money.rupees(50000),
        daysOfData: 15,
        asOf: DateTime(2026, 8, 15),
      );
      expect(forecast.status, ForecastStatus.empty);
      expect(forecast.daysUntilEmpty, isNull);
    });

    test('accounts for months of different lengths', () {
      SpendForecast on(DateTime date) => SpendForecast.compute(
            onHand: Money.rupees(20000),
            spentInWindow: Money.rupees(20000),
            daysOfData: 20,
            asOf: date,
          );

      expect(on(DateTime(2026, 8, 20)).daysLeftInMonth, 11);
      expect(on(DateTime(2026, 2, 20)).daysLeftInMonth, 8);
    });
  });

  group('clampDayToMonth', () {
    test('keeps a valid day untouched', () {
      expect(clampDayToMonth(15, DateTime(2026, 8, 1)), 15);
    });

    test('pulls the 31st back to the last day of a short month', () {
      // A salary set for the 31st still has to land in February.
      expect(clampDayToMonth(31, DateTime(2026, 2, 1)), 28);
      expect(clampDayToMonth(31, DateTime(2026, 4, 1)), 30);
      expect(clampDayToMonth(31, DateTime(2026, 8, 1)), 31);
    });

    test('handles a leap February', () {
      expect(clampDayToMonth(30, DateTime(2028, 2, 1)), 29);
    });

    test('never returns a day below one', () {
      expect(clampDayToMonth(0, DateTime(2026, 8, 1)), 1);
      expect(clampDayToMonth(-5, DateTime(2026, 8, 1)), 1);
    });
  });

  group('MonthPeriod', () {
    test('formats as a sortable year-month', () {
      expect(MonthPeriod.of(DateTime(2026, 8, 6)), '2026-08');
      expect(MonthPeriod.of(DateTime(2026, 12, 31)), '2026-12');
    });

    test('is the same for every day within one month', () {
      expect(
        MonthPeriod.of(DateTime(2026, 8, 1)),
        MonthPeriod.of(DateTime(2026, 8, 31)),
      );
    });

    test('differs across months, which is what stops a double-post', () {
      expect(
        MonthPeriod.of(DateTime(2026, 8, 31)) ==
            MonthPeriod.of(DateTime(2026, 9, 1)),
        isFalse,
      );
    });
  });
}
