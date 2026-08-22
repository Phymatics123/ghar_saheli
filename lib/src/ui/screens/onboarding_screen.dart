import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../domain/chart_of_accounts.dart';
import '../app_scope.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/money_text.dart';
import '../widgets/numeric_keypad.dart';

/// First launch: pick a language, then say how much money there is right now.
///
/// The opening balance question is not paperwork. A ledger that starts at zero
/// shows a negative balance the moment the first expense is recorded, which
/// reads as broken and is the sort of thing that makes someone put the app
/// down on day one. Asking once, in plain words, avoids that — and it is
/// skippable, because a user who does not want to answer should not be blocked
/// at the door.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _languageChosen = false;
  String _digits = '';
  bool _saving = false;

  Money get _amount =>
      _digits.isEmpty ? Money.zero : Money.rupees(int.parse(_digits));

  Future<void> _finish({required bool withBalance}) async {
    if (_saving) return;
    setState(() => _saving = true);

    final AppSettings settings = AppScope.settingsRead(context);
    final ledger = AppScope.ledgerRead(context);

    if (withBalance && !_amount.isZero) {
      await ledger.setOpeningBalance(
        accountId: AccountCodes.idOf(AccountCodes.cash),
        amount: _amount,
      );
    }
    await settings.markOnboarded();
    if (!mounted) return;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _languageChosen ? _buildBalanceStep() : _buildLanguageStep(),
      ),
    );
  }

  Widget _buildLanguageStep() {
    final S s = AppScope.stringsOf(context);
    final AppSettings settings = AppScope.settingsOf(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: <Widget>[
          const Spacer(),
          Text(s.appName, style: theme.textTheme.displayLarge),
          const SizedBox(height: 8),
          Text(
            s.welcomeLine,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.inkSoft),
          ),
          const SizedBox(height: 40),
          Text(s.chooseLanguage, style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          // Each option is written in its own script, so it is legible to
          // someone who cannot read the other two.
          for (final AppLanguage language in AppLanguage.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LanguageOption(
                language: language,
                selected: settings.language == language,
                onTap: () => settings.setLanguage(language),
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => setState(() => _languageChosen = true),
              child: Text(s.start),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildBalanceStep() {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        // Flexible for the same reason as the entry screen: a fixed column
        // ending in a Spacer only works while the content fits, and the phones
        // this app is aimed at are not all the same height. The help text here
        // wraps to three lines in Urdu on a narrow screen, which is exactly
        // the kind of thing that overflows a rigid layout.
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: <Widget>[
                      Text(
                        s.howMuchNow,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.howMuchNowHelp,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                MoneyText(
                  _amount,
                  alwaysVisible: true,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: _digits.isEmpty ? AppTheme.inkSoft : AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: NumericKeypad(
            onDigit: (String digit) {
              if (_digits.length + digit.length > 9) return;
              if (_digits.isEmpty && digit == '00') return;
              setState(() =>
                  _digits = (_digits + digit).replaceFirst(RegExp(r'^0+'), ''));
            },
            onBackspace: () {
              if (_digits.isEmpty) return;
              setState(() => _digits = _digits.substring(0, _digits.length - 1));
            },
            onBackspaceLongPress: () => setState(() => _digits = ''),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : () => _finish(withBalance: true),
              child: Text(s.start),
            ),
          ),
        ),
        TextButton(
          onPressed: _saving ? null : () => _finish(withBalance: false),
          child: Text(s.notNow),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primary.withValues(alpha: 0.10) : AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  language.ownName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
