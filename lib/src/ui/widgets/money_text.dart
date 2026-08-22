import 'package:flutter/widgets.dart';

import '../../core/money.dart';
import '../app_scope.dart';

/// Displays an amount.
///
/// Always laid out left-to-right, even when the rest of the screen is Urdu.
/// "Rs 2,500" is a single unit and a bidirectional layout will happily push the
/// "Rs" to the far side of the number or reorder the digit groups. Amounts also
/// stay in Latin digits rather than Urdu-Arabic ones — that is how every
/// utility bill, bank slip and price tag in Pakistan writes money, so it is
/// what a user reads fastest.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    this.style,
    this.symbol = true,
    this.signPrefix = false,
    this.alwaysVisible = false,
    super.key,
  });

  final Money amount;
  final TextStyle? style;
  final bool symbol;

  /// Shows an explicit `+` for money coming in. Off by default; used in lists
  /// where income and expense sit side by side.
  final bool signPrefix;

  /// Set on the one or two places that must stay readable even with masking
  /// on — the amount you are typing right now, for instance, since hiding
  /// that would make the keypad unusable rather than private.
  final bool alwaysVisible;

  @override
  Widget build(BuildContext context) {
    final bool masked =
        !alwaysVisible && AppScope.settingsOf(context).maskAmounts;

    final String text;
    if (masked) {
      // Fixed width regardless of the real figure. Dots that grew with the
      // number would leak how large it is, which defeats the point.
      text = symbol ? 'Rs ••••' : '••••';
    } else {
      final String prefix = signPrefix && amount.isPositive ? '+' : '';
      text = '$prefix${amount.format(symbol: symbol)}';
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
