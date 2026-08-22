import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/numeric_keypad.dart';

enum PinMode {
  /// Shown over the app on launch when a PIN is set.
  unlock,

  /// Creating or replacing the PIN, from settings.
  create,
}

const int kPinLength = 4;

/// The PIN screen, for both unlocking and setting a code.
///
/// Four digits, no letters, no "forgot PIN" flow. There is no account to
/// recover through and nothing is stored off the phone, so a reset link is not
/// a thing that could exist here — the honest fallback is that the lock can be
/// turned off from settings by whoever knows the code.
class PinScreen extends StatefulWidget {
  const PinScreen({
    required this.mode,
    this.onUnlocked,
    super.key,
  });

  final PinMode mode;

  /// Called once the entered PIN verifies. Only used in [PinMode.unlock].
  final VoidCallback? onUnlocked;

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _entered = '';
  String? _firstEntry;
  String? _error;
  bool _busy = false;

  bool get _isConfirmStep => _firstEntry != null;

  String _title(S s) {
    if (widget.mode == PinMode.unlock) return s.enterPin;
    return _isConfirmStep ? s.confirmPin : s.setPin;
  }

  Future<void> _onDigit(String digit) async {
    if (_busy || _entered.length >= kPinLength) return;

    setState(() {
      _entered += digit;
      _error = null;
    });

    if (_entered.length == kPinLength) {
      await _submit();
    }
  }

  void _onBackspace() {
    if (_busy || _entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _submit() async {
    final S s = AppScope.stringsOf(context);
    final AppScope scope = AppScope.read(context);

    // Looked up lazily, and only in create mode. Unlocking draws this screen
    // as an overlay above the navigator rather than as a route inside it, so
    // there is no Navigator ancestor to find and asking for one would throw.
    NavigatorState? navigator;
    if (widget.mode == PinMode.create) {
      navigator = Navigator.of(context);
    }

    setState(() => _busy = true);
    final String value = _entered;

    if (widget.mode == PinMode.unlock) {
      final bool ok = await scope.pin.verify(value);
      if (!mounted) return;
      if (ok) {
        widget.onUnlocked?.call();
        return;
      }
      await HapticFeedback.heavyImpact();
      setState(() {
        _entered = '';
        _busy = false;
        _error = s.wrongPin;
      });
      return;
    }

    // Creating a PIN: first entry, then confirmation.
    if (!_isConfirmStep) {
      setState(() {
        _firstEntry = value;
        _entered = '';
        _busy = false;
      });
      return;
    }

    if (_firstEntry != value) {
      await HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() {
        _firstEntry = null;
        _entered = '';
        _busy = false;
        _error = s.pinsDoNotMatch;
      });
      return;
    }

    await scope.pin.setPin(value);
    if (!mounted) return;
    AppScope.settingsRead(context).setHasPin(true);
    // Only reachable in create mode, which is always pushed as a route.
    navigator!.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: widget.mode == PinMode.create ? AppBar() : null,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(),
            Icon(
              widget.mode == PinMode.unlock ? Icons.lock_outline : Icons.pin,
              size: 44,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(_title(s), style: theme.textTheme.titleLarge),
            const SizedBox(height: 22),
            _PinDots(filled: _entered.length),
            const SizedBox(height: 14),
            SizedBox(
              height: 22,
              child: _error == null
                  ? null
                  : Text(
                      _error!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.spend),
                    ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: NumericKeypad(
                showDoubleZero: false,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < kPinLength; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(horizontal: 9),
            height: 17,
            width: 17,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? AppTheme.primary : Colors.transparent,
              border: Border.all(
                color: i < filled ? AppTheme.primary : AppTheme.inkSoft,
                width: 2,
              ),
            ),
          ),
      ],
    );
  }
}
