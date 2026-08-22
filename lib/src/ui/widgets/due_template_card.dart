import 'package:flutter/material.dart';

import '../../domain/recurring.dart';
import '../app_scope.dart';
import '../category_icons.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/money_text.dart';

/// A bill that is due and has not been recorded yet.
///
/// Shown in the app rather than pushed as a phone notification, and that is a
/// deliberate choice rather than a missing feature. Scheduled alarms are killed
/// aggressively by the battery managers on exactly the budget phones this app
/// targets, so a notification is a promise the OS may quietly break. A card at
/// the top of the screen the user already opens is a reminder that cannot be
/// silently dropped.
///
/// Confirming never happens by itself. The app does not know whether the rent
/// was actually paid, and a ledger that invents entries is worse than one that
/// asks.
class DueTemplateCard extends StatelessWidget {
  const DueTemplateCard({
    required this.due,
    required this.onConfirm,
    super.key,
  });

  final DueTemplate due;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);
    final Color accent = colorForIcon(due.category.iconKey);
    final bool late = due.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: late
              ? AppTheme.spend.withValues(alpha: 0.45)
              : AppTheme.divider,
        ),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 21,
            backgroundColor: accent.withValues(alpha: 0.14),
            child: Icon(iconForKey(due.category.iconKey),
                color: accent, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  due.template.description,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Text(
                      late ? s.overdueBy(due.daysLate) : s.dueToday,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: late ? AppTheme.spend : AppTheme.inkSoft,
                        fontWeight: late ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (!due.isVariableAmount) ...<Widget>[
                      Text(' · ', style: theme.textTheme.bodySmall),
                      MoneyText(
                        due.amount,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: AppTheme.primary,
              textStyle: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            child: Text(s.confirm),
          ),
        ],
      ),
    );
  }
}
