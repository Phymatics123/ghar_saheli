import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// A large on-screen number pad, used for both amounts and the PIN.
///
/// The app draws its own instead of using the system keyboard for three
/// reasons: the system keyboard on a budget phone eats over half the screen,
/// it opens on letters rather than digits unless coaxed, and its layout
/// changes with whichever keyboard app the user installed. A fixed pad with
/// big keys is the same every time, which matters more than flexibility when
/// the same three taps get repeated every day.
///
/// Always laid out left-to-right. 1-2-3 reads left to right on every calculator
/// and phone dialer in the world, including in Urdu, so mirroring it in RTL
/// would be wrong rather than considerate.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    required this.onDigit,
    required this.onBackspace,
    this.showDoubleZero = true,
    this.onBackspaceLongPress,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  /// Clears everything. Wired to a long press so a mistyped amount does not
  /// need six taps to undo.
  final VoidCallback? onBackspaceLongPress;

  /// The `00` key. Useful when most amounts end in hundreds, useless for a
  /// four-digit PIN.
  final bool showDoubleZero;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _row(<String>['1', '2', '3']),
          _row(<String>['4', '5', '6']),
          _row(<String>['7', '8', '9']),
          Row(
            children: <Widget>[
              Expanded(
                child: showDoubleZero
                    ? _KeypadKey(label: '00', onTap: () => onDigit('00'))
                    : const SizedBox.shrink(),
              ),
              Expanded(child: _KeypadKey(label: '0', onTap: () => onDigit('0'))),
              Expanded(
                child: _KeypadKey(
                  icon: Icons.backspace_outlined,
                  onTap: onBackspace,
                  onLongPress: onBackspaceLongPress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(List<String> digits) {
    return Row(
      children: <Widget>[
        for (final String digit in digits)
          Expanded(
            child: _KeypadKey(label: digit, onTap: () => onDigit(digit)),
          ),
      ],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    this.label,
    this.icon,
    required this.onTap,
    this.onLongPress,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // A short buzz confirms the tap landed. On a cheap screen the
            // visual ripple alone is easy to miss.
            HapticFeedback.selectionClick();
            onTap();
          },
          onLongPress: onLongPress == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onLongPress!();
                },
          child: SizedBox(
            height: 62,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 26, color: AppTheme.ink)
                  : Text(
                      label!,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
