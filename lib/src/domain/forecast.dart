import '../core/money.dart';
import 'recurring.dart';

enum ForecastStatus {
  /// Too early in the month to say anything honest.
  notEnoughData,

  /// The money outlasts the month with room to spare.
  comfortable,

  /// It reaches the end of the month, but only just.
  tight,

  /// It runs out first.
  willRunOut,

  /// It already has.
  empty,
}

/// How long the money lasts at the current rate of spending.
///
/// This is the number the research kept pointing at. Households described the
/// same thing over and over — the salary runs out ten days before the month
/// does, and nobody sees it coming until it happens. A ledger that only records
/// the past does not help with that; the useful thing is a warning while there
/// is still time to change something.
///
/// Deliberately needs no budget to be set up. Cash in hand divided by the daily
/// burn rate answers the question with data the app already has, so it starts
/// working on its own rather than after a configuration screen nobody fills in.
///
/// The average runs over a rolling thirty-day window rather than the current
/// month, and divides by the days there is genuinely data for. That handles
/// the two things a month-to-date average gets wrong: it does not collapse on
/// the 1st, and it does not assume the ledger has been kept since the start of
/// the month when the app may have been installed halfway through.
///
/// Known limitation, stated plainly: it is still a flat mean, so a single
/// unusual purchase — a wedding gift, a hospital bill — pulls the estimate for
/// a while. A model that set aside one-off outliers would read truer, and
/// needs a few months of history this app does not have yet.
class SpendForecast {
  const SpendForecast({
    required this.status,
    required this.onHand,
    required this.dailyBurn,
    required this.daysUntilEmpty,
    required this.daysLeftInMonth,
  });

  final ForecastStatus status;
  final Money onHand;

  /// Average spent per day so far this month.
  final Money dailyBurn;

  /// Whole days the money lasts at that rate. Null when there is no forecast.
  final int? daysUntilEmpty;

  final int daysLeftInMonth;

  /// Below this many days of *recorded spending*, one large shop skews the
  /// average enough to produce a frightening and wrong answer. Saying nothing
  /// is better than saying something untrue about someone's money.
  static const int minimumDaysOfData = 5;

  /// Days of spending the burn rate is averaged over.
  ///
  /// A rolling window rather than "this month so far", for two reasons. It
  /// does not collapse on the 1st, when a month-to-date average would be built
  /// from a single day. And it always spans a full monthly cycle, so the big
  /// raashan shop at the start of the month is amortised across the weeks it
  /// actually feeds rather than dominating the average.
  static const int windowDays = 30;

  /// Averages spending over the days there is actually data for.
  ///
  /// [spentInWindow] is what left the household in the last [windowDays].
  /// [daysOfData] is how many days that figure genuinely covers — from the
  /// first recorded entry to today, capped at the window.
  ///
  /// That second figure is the whole correction. This used to divide by the
  /// day of the month, which quietly assumed the ledger had been kept since
  /// the 1st. It had not: someone installing on the 20th with three days of
  /// entries had their spending divided by twenty, producing a burn rate
  /// roughly seven times too low and a forecast that cheerfully promised money
  /// would last months. Dividing by observed days instead makes the average
  /// mean what it says.
  factory SpendForecast.compute({
    required Money onHand,
    required Money spentInWindow,
    required int daysOfData,
    required DateTime asOf,
  }) {
    final int daysLeft = daysInMonth(asOf) - asOf.day;

    SpendForecast bare(ForecastStatus status) => SpendForecast(
          status: status,
          onHand: onHand,
          dailyBurn: Money.zero,
          daysUntilEmpty: null,
          daysLeftInMonth: daysLeft,
        );

    if (!onHand.isPositive) return bare(ForecastStatus.empty);

    if (daysOfData < minimumDaysOfData || !spentInWindow.isPositive) {
      return bare(ForecastStatus.notEnoughData);
    }

    final int observed =
        daysOfData > windowDays ? windowDays : daysOfData;
    final Money dailyBurn = Money(spentInWindow.paisa ~/ observed);
    if (!dailyBurn.isPositive) return bare(ForecastStatus.notEnoughData);

    final int daysUntilEmpty = onHand.paisa ~/ dailyBurn.paisa;

    final ForecastStatus status;
    if (daysUntilEmpty >= daysLeft + 3) {
      status = ForecastStatus.comfortable;
    } else if (daysUntilEmpty >= daysLeft) {
      status = ForecastStatus.tight;
    } else {
      status = ForecastStatus.willRunOut;
    }

    return SpendForecast(
      status: status,
      onHand: onHand,
      dailyBurn: dailyBurn,
      daysUntilEmpty: daysUntilEmpty,
      daysLeftInMonth: daysLeft,
    );
  }

  /// Whether this is worth taking room on the home screen for.
  bool get isWorthShowing =>
      status != ForecastStatus.notEnoughData;
}
