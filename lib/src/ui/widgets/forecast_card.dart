import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../domain/forecast.dart';
import '../app_scope.dart';
import '../strings.dart';
import '../theme.dart';

/// The "your money runs out in six days" line.
///
/// Colour carries the message as much as the words do — this is meant to be
/// understood from across the room, and a user who reads slowly should not have
/// to finish the sentence to know whether the news is good.
///
/// It stays quiet when there is nothing trustworthy to say. An app that cries
/// wolf on the second of the month gets ignored by the twentieth.
class ForecastCard extends StatelessWidget {
  const ForecastCard({required this.forecast, super.key});

  final SpendForecast forecast;

  @override
  Widget build(BuildContext context) {
    if (!forecast.isWorthShowing) return const SizedBox.shrink();

    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);
    final _Look look = _lookFor(forecast.status);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: look.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: look.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Icon(look.icon, color: look.accent, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _message(s),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: look.accent,
                  ),
                ),
                if (forecast.dailyBurn.isPositive) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    s.dailyAverage(forecast.dailyBurn.format()),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _message(S s) {
    return switch (forecast.status) {
      ForecastStatus.empty => s.nothingLeft,
      ForecastStatus.willRunOut => s.daysUntilEmpty(forecast.daysUntilEmpty!),
      ForecastStatus.tight => s.justAboutLasts,
      ForecastStatus.comfortable => s.lastsThroughMonth,
      ForecastStatus.notEnoughData => '',
    };
  }

  _Look _lookFor(ForecastStatus status) {
    return switch (status) {
      ForecastStatus.empty || ForecastStatus.willRunOut => const _Look(
          accent: AppTheme.spend,
          background: Color(0xFFFDEDED),
          icon: Icons.warning_amber_rounded,
        ),
      ForecastStatus.tight => const _Look(
          accent: Color(0xFFB26A00),
          background: Color(0xFFFFF6E5),
          icon: Icons.hourglass_bottom,
        ),
      _ => const _Look(
          accent: AppTheme.earn,
          background: Color(0xFFEDF7ED),
          icon: Icons.check_circle_outline,
        ),
    };
  }
}

class _Look {
  const _Look({
    required this.accent,
    required this.background,
    required this.icon,
  });

  final Color accent;
  final Color background;
  final IconData icon;
}

/// Builds the forecast from what the home screen already has on hand.
SpendForecast buildForecast({
  required Money onHand,
  required Money spentInWindow,
  required int daysOfData,
}) {
  return SpendForecast.compute(
    onHand: onHand,
    spentInWindow: spentInWindow,
    daysOfData: daysOfData,
    asOf: DateTime.now(),
  );
}
