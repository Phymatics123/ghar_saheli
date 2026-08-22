import 'package:flutter/material.dart';

import '../engine.dart';
import '../security/pin_service.dart';
import 'app_scope.dart';
import 'screens/activation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/pin_screen.dart';
import 'strings.dart';
import 'theme.dart';

/// Root of the app.
class GharSaheliApp extends StatelessWidget {
  const GharSaheliApp({
    required this.engine,
    required this.pin,
    required this.settings,
    super.key,
  });

  final GharSaheliEngine engine;
  final PinService pin;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      engine: engine,
      pin: pin,
      settings: settings,
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  /// Lets the lock be pushed from outside the navigator's own subtree.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final AppSettings settings = AppScope.settingsOf(context);

    return MaterialApp(
      title: 'Ghar Saheli',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(settings.language),
      navigatorKey: _navigatorKey,

      // Direction is set here rather than through a locale because Material's
      // widgets need a `MaterialLocalizations`, and MaterialApp only ships
      // English unless `flutter_localizations` is added. Every string in this
      // app is hand-written and the few localised Material widgets are
      // avoided, so a Directionality gives correct right-to-left layout for
      // Urdu without the dependency or the bytes.
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: settings.language.isRtl
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: _PrivacyShield(
            navigatorKey: _navigatorKey,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },

      home: const _StartRoute(),
    );
  }
}

/// Onboarding until it is done, then the ledger.
class _StartRoute extends StatefulWidget {
  const _StartRoute();

  @override
  State<_StartRoute> createState() => _StartRouteState();
}

class _StartRouteState extends State<_StartRoute> {
  @override
  Widget build(BuildContext context) {
    final AppSettings settings = AppScope.settingsOf(context);

    // Activation first, then onboarding, then the ledger. Each step writes a
    // flag to local storage, so a returning user drops straight through all
    // of them to the home screen.
    if (!settings.licensed) {
      return ActivationScreen(onActivated: () => setState(() {}));
    }
    if (!settings.onboarded) {
      return OnboardingScreen(onDone: () => setState(() {}));
    }
    return const HomeScreen();
  }
}

/// Hides the app when it leaves the foreground, and asks for the PIN again
/// after it has been away.
///
/// The lock is **pushed as a route** rather than drawn as an overlay here. An
/// earlier version stacked a whole Scaffold beside the Navigator inside
/// `MaterialApp.builder`; that put a screen outside the navigator's subtree
/// while it still depended on widgets above it, and Flutter tore the tree down
/// with "Tried to build dirty widget in the wrong build scope" and a failed
/// `_dependents.isEmpty` assertion. A route on the root navigator sits above
/// every other screen by definition, which is what was wanted, and it is an
/// ordinary part of the tree.
///
/// What stays here is only the curtain: a plain coloured box with a word on
/// it, drawn over everything while the app is in the recents list so the
/// balance is not sitting in Android's screenshot of it.
class _PrivacyShield extends StatefulWidget {
  const _PrivacyShield({
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<_PrivacyShield> createState() => _PrivacyShieldState();
}

class _PrivacyShieldState extends State<_PrivacyShield>
    with WidgetsBindingObserver {
  bool _obscured = false;
  bool _lockShowing = false;
  DateTime? _leftAt;

  /// Long enough that the share sheet, the file picker and a permission
  /// dialog do not count as leaving. Without it, exporting a backup would
  /// demand the PIN on the way back from the screen that started it.
  static const Duration _grace = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // After the first frame, so the navigator exists to push onto.
    WidgetsBinding.instance.addPostFrameCallback((_) => _lockIfNeeded());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      final DateTime? leftAt = _leftAt;
      final bool wasAwayLong =
          leftAt != null && DateTime.now().difference(leftAt) > _grace;

      setState(() => _obscured = false);
      _leftAt = null;
      if (wasAwayLong) _lockIfNeeded();
      return;
    }

    setState(() => _obscured = true);
    _leftAt ??= DateTime.now();
  }

  void _lockIfNeeded() {
    if (_lockShowing || !mounted) return;
    // Read rather than depend: this runs from a callback, not a build.
    if (!AppScope.settingsRead(context).hasPin) return;

    final NavigatorState? navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;

    _lockShowing = true;
    navigator.push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (BuildContext context, _, __) {
          return PopScope(
            // The back button must not dismiss a lock.
            canPop: false,
            child: PinScreen(
              mode: PinMode.unlock,
              onUnlocked: () {
                _lockShowing = false;
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Without this the navigator is handed loose constraints and sizes
      // itself to its content rather than the screen.
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        if (_obscured) const _Curtain(),
      ],
    );
  }
}

/// Deliberately plain: no Scaffold, no theme lookup, no inherited widgets
/// beyond the Directionality directly above it. It exists for the fraction of
/// a second Android needs to photograph the screen.
class _Curtain extends StatelessWidget {
  const _Curtain();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.primary,
      child: Center(
        child: Text(
          'Ghar Saheli',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
