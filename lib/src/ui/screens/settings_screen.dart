import 'package:flutter/material.dart';


import '../../dev_home.dart';
import '../app_scope.dart';
import '../strings.dart';
import '../theme.dart';
import 'backup_screen.dart';
import 'bill_calculator_screen.dart';
import 'pin_screen.dart';
import 'staff_screen.dart';
import 'templates_screen.dart';
import 'update_screen.dart';

/// Language, lock, and nothing else.
///
/// Deliberately short. Every setting is one more thing to understand before the
/// app can be used, and none of what is usually on this screen — accounts,
/// sync, notifications, backup destinations — exists in an app that keeps
/// everything on one phone.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final AppSettings settings = AppScope.settingsOf(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          _SectionLabel(s.language),
          Card(
            child: Column(
              children: <Widget>[
                for (final AppLanguage language in AppLanguage.values)
                  ListTile(
                    title: Text(
                      language.ownName,
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: settings.language == language
                        ? const Icon(Icons.check_circle,
                            color: AppTheme.primary)
                        : const Icon(Icons.circle_outlined,
                            color: AppTheme.inkSoft),
                    onTap: () => settings.setLanguage(language),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _SectionLabel(s.staff),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: Text(s.staff, style: theme.textTheme.bodyLarge),
                  subtitle:
                      Text(s.staffHelp, style: theme.textTheme.bodySmall),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StaffScreen(),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title:
                      Text(s.billCalculator, style: theme.textTheme.bodyLarge),
                  subtitle: Text(s.billCalculatorHelp,
                      style: theme.textTheme.bodySmall),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BillCalculatorScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _SectionLabel(s.monthlyBills),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_repeat),
              title: Text(s.monthlyBills, style: theme.textTheme.bodyLarge),
              subtitle: Text(s.monthlyBillsHelp,
                  style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TemplatesScreen(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),
          _SectionLabel(s.privacy),
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  value: settings.maskAmounts,
                  secondary: const Icon(Icons.visibility_off_outlined),
                  title: Text(s.hideAmounts, style: theme.textTheme.bodyLarge),
                  subtitle: Text(s.hideAmountsHelp,
                      style: theme.textTheme.bodySmall),
                  onChanged: settings.setMaskAmounts,
                ),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: Text(s.backup, style: theme.textTheme.bodyLarge),
                  subtitle:
                      Text(s.backupHelp, style: theme.textTheme.bodySmall),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BackupScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _SectionLabel(s.lock),
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  value: settings.hasPin,
                  title: Text(s.lock, style: theme.textTheme.bodyLarge),
                  subtitle: Text(s.lockOn, style: theme.textTheme.bodySmall),
                  onChanged: (bool wanted) =>
                      _toggleLock(context, s, wanted: wanted),
                ),
                if (settings.hasPin)
                  ListTile(
                    leading: const Icon(Icons.password),
                    title: Text(s.changePin, style: theme.textTheme.bodyLarge),
                    onTap: () => _createPin(context, s),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.phonelink_lock_outlined,
                    size: 18, color: AppTheme.inkSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.privacyLine, style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          _SectionLabel(s.appUpdate),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.system_update),
                  title: Text(s.checkForUpdates,
                      style: theme.textTheme.bodyLarge),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const UpdateScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          // Kept reachable rather than deleted: it is the fastest way to see
          // whether the ledger underneath is behaving on a given device.
          TextButton.icon(
            icon: const Icon(Icons.build_outlined, size: 18),
            label: Text(s.engineCheck),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    DevHomePage(engine: AppScope.read(context).engine),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLock(
    BuildContext context,
    S s, {
    required bool wanted,
  }) async {
    final AppScope scope = AppScope.read(context);
    final AppSettings settings = AppScope.settingsRead(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    if (wanted) {
      await _createPin(context, s);
      return;
    }

    await scope.pin.clear();
    settings.setHasPin(false);
    messenger.showSnackBar(SnackBar(content: Text(s.pinRemoved)));
  }

  Future<void> _createPin(BuildContext context, S s) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const PinScreen(mode: PinMode.create),
      ),
    );
    if (saved == true) {
      messenger.showSnackBar(SnackBar(content: Text(s.pinSaved)));
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: AppTheme.inkSoft),
      ),
    );
  }
}
