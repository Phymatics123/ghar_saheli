import 'package:flutter/widgets.dart';

import '../domain/ledger_repository.dart';
import '../engine.dart';
import '../security/pin_service.dart';
import 'strings.dart';

/// Settings that change how the app looks, held in memory and mirrored into
/// the same `app_meta` table the ledger uses.
///
/// A `ChangeNotifier` rather than a state-management package: there are two
/// values here, and every screen that shows data already listens to the
/// database through streams. Pulling in a dependency to hold a language enum
/// would be weight for nothing on an APK with a size budget.
class AppSettings extends ChangeNotifier {
  AppSettings._({
    required LedgerRepository ledger,
    required AppLanguage language,
    required bool hasPin,
  })  : _ledger = ledger,
        _language = language,
        _hasPin = hasPin;

  static const String _languageKey = 'ui.language';
  static const String _onboardedKey = 'ui.onboarded';
  static const String _maskAmountsKey = 'ui.mask_amounts';
  static const String _licensedKey = 'license.activated';

  final LedgerRepository _ledger;

  AppLanguage _language;
  bool _hasPin;
  bool _onboarded = false;
  bool _maskAmounts = false;
  bool _licensed = false;

  AppLanguage get language => _language;
  bool get hasPin => _hasPin;
  bool get onboarded => _onboarded;

  /// Whether an activation code has been accepted on this phone.
  ///
  /// Written once, after the only network call the app ever needs to make.
  /// From then on the check is local, so the app keeps working with no
  /// internet at all — which is the whole point of it.
  bool get licensed => _licensed;

  /// Replaces every amount on screen with dots.
  ///
  /// For the moment someone leans over to look. The research behind this app
  /// found shame around money to be a real barrier — women described borrowing
  /// from relatives as humiliating — and phones in these households are often
  /// shared rather than owned. Hiding the numbers without hiding the app lets
  /// someone keep using it in company.
  bool get maskAmounts => _maskAmounts;

  /// Strings in the currently chosen language.
  S get s => S(_language);

  static Future<AppSettings> load({
    required LedgerRepository ledger,
    required PinService pin,
  }) async {
    final String? stored = await ledger.readMeta(_languageKey);
    final bool hasPin = await pin.isSet();
    final String? onboarded = await ledger.readMeta(_onboardedKey);
    final String? masked = await ledger.readMeta(_maskAmountsKey);
    final String? licensed = await ledger.readMeta(_licensedKey);

    final AppSettings settings = AppSettings._(
      ledger: ledger,
      language: AppLanguageInfo.fromStorage(stored),
      hasPin: hasPin,
    );
    settings._onboarded = onboarded == 'true';
    settings._maskAmounts = masked == 'true';
    settings._licensed = licensed == 'true';
    return settings;
  }

  Future<void> markLicensed() async {
    if (_licensed) return;
    _licensed = true;
    notifyListeners();
    await _ledger.writeMeta(_licensedKey, 'true');
  }

  Future<void> setMaskAmounts(bool value) async {
    if (value == _maskAmounts) return;
    _maskAmounts = value;
    notifyListeners();
    await _ledger.writeMeta(_maskAmountsKey, value.toString());
  }

  Future<void> setLanguage(AppLanguage value) async {
    if (value == _language) return;
    _language = value;
    notifyListeners();
    await _ledger.writeMeta(_languageKey, value.storageKey);
  }

  Future<void> markOnboarded() async {
    _onboarded = true;
    notifyListeners();
    await _ledger.writeMeta(_onboardedKey, 'true');
  }

  /// Called after the PIN is created or removed, so the lock screen and the
  /// settings toggle agree without either having to re-read the database.
  void setHasPin(bool value) {
    if (value == _hasPin) return;
    _hasPin = value;
    notifyListeners();
  }
}

/// Hands the engine and settings down the widget tree.
class AppScope extends InheritedNotifier<AppSettings> {
  const AppScope({
    required this.engine,
    required this.pin,
    required AppSettings settings,
    required super.child,
    super.key,
  }) : super(notifier: settings);

  final GharSaheliEngine engine;
  final PinService pin;

  /// For use inside `build`. Registers a dependency, so the caller rebuilds
  /// when settings change.
  static AppScope of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!;
  }

  /// For use outside `build` — `initState`, lifecycle callbacks, button
  /// handlers. Reads the same values without registering a dependency.
  ///
  /// Registering one outside the build phase is what caused a
  /// `_dependents.isEmpty` assertion to bring the app down after a few
  /// minutes: a dependency taken in `initState` is not always unregistered
  /// when the widget goes away, so stale entries pile up on this element and
  /// trip the framework's check when the tree is torn down. Nothing here needs
  /// to rebuild in response to a change anyway — these callers read a value
  /// once and act on it.
  static AppScope read(BuildContext context) {
    final AppScope? scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!;
  }

  static AppSettings settingsRead(BuildContext context) =>
      read(context).notifier!;

  static LedgerRepository ledgerRead(BuildContext context) =>
      read(context).engine.ledger;

  static LedgerRepository ledgerOf(BuildContext context) =>
      of(context).engine.ledger;

  static AppSettings settingsOf(BuildContext context) => of(context).notifier!;

  /// Shorthand for the strings, since nearly every widget needs them.
  static S stringsOf(BuildContext context) => settingsOf(context).s;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      super.updateShouldNotify(oldWidget) ||
      engine != oldWidget.engine ||
      pin != oldWidget.pin;
}
