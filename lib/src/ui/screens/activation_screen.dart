import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/license_service.dart';
import '../app_scope.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/fill_viewport_scroll.dart';

/// The first screen on a fresh install: enter the code that came with the app.
///
/// This is the only point in the app's life where the internet is required.
/// Once a code is accepted the answer is stored on the phone and never asked
/// again, so the ledger itself stays as offline as it always was.
///
/// There is deliberately no way past this screen. A skip button would make the
/// code meaningless, and an app that quietly works without one is not a thing
/// anybody would pay for.
class ActivationScreen extends StatefulWidget {
  const ActivationScreen({required this.onActivated, super.key});

  final VoidCallback onActivated;

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _controller = TextEditingController();
  final LicenseService _service = const LicenseService();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Reformats as the user types, so the dashes appear on their own and a code
  /// pasted from WhatsApp in any shape ends up looking like the one printed on
  /// the message.
  void _onChanged(String raw) {
    final String tidy = LicenseService.normalise(raw);
    if (tidy != raw) {
      _controller.value = TextEditingValue(
        text: tidy,
        selection: TextSelection.collapsed(offset: tidy.length),
      );
    }
    // Always rebuild, not only when clearing an error.
    //
    // The Activate button's enabled state is worked out in build() from the
    // field's contents. Rebuilding only on the error path meant that in the
    // ordinary case — no error showing — typing a complete code never
    // triggered a rebuild, so the button stayed grey however much was typed.
    setState(() => _error = null);
  }

  Future<void> _activate() async {
    final S s = AppScope.stringsOf(context);
    final AppSettings settings = AppScope.settingsRead(context);

    setState(() {
      _busy = true;
      _error = null;
    });

    final LicenseResult result = await _service.redeem(_controller.text);
    if (!mounted) return;

    switch (result) {
      case LicenseResult.activated:
        await HapticFeedback.mediumImpact();
        await settings.markLicensed();
        if (!mounted) return;
        widget.onActivated();
      case LicenseResult.rejected:
        await HapticFeedback.heavyImpact();
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = s.activateRejected;
        });
      case LicenseResult.offline:
        setState(() {
          _busy = false;
          _error = s.activateOffline;
        });
      case LicenseResult.serverError:
        setState(() {
          _busy = false;
          _error = s.activateServerError;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);
    final bool canSubmit =
        !_busy && LicenseService.looksComplete(_controller.text);

    return Scaffold(
      body: SafeArea(
        // Scrollable rather than a fixed column with Spacers. This screen
        // autofocuses the field, so the keyboard is up before the user has
        // done anything — on a shorter phone that left too little room and the
        // layout overflowed by a few pixels.
        //
        // The Spacers are kept: they are what holds the footnote at the bottom
        // of a tall screen. FillViewportScroll is what makes them legal inside
        // a scroll view, which they are emphatically not on their own.
        child: FillViewportScroll(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: <Widget>[
              const Spacer(),
              const Icon(Icons.vpn_key_outlined,
                  size: 48, color: AppTheme.primary),
              const SizedBox(height: 18),
              Text(s.appName, style: theme.textTheme.displayLarge),
              const SizedBox(height: 6),
              Text(
                s.activateTitle,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                s.activateHelp,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.inkSoft),
              ),
              const SizedBox(height: 26),

              // Left to right whatever the app's language: the code itself is
              // Latin letters and digits, and mirroring it would make it read
              // back differently from the message it was copied out of.
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  enabled: !_busy,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: _onChanged,
                  onSubmitted: (_) => canSubmit ? _activate() : null,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'XXXX-XXXX-XXXX-XXXX',
                    labelText: s.activateCodeLabel,
                    border: const OutlineInputBorder(),
                    errorText: _error,
                    errorMaxLines: 3,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canSubmit ? _activate : null,
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(s.activateButton),
                ),
              ),

              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.info_outline,
                      size: 16, color: AppTheme.inkSoft),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.activateOnceOnly,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
