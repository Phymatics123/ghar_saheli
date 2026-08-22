import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/database.dart';
import '../../domain/account_type.dart';
import '../../domain/models.dart';
import '../../domain/recurring.dart';
import '../app_scope.dart';
import '../category_icons.dart';
import '../strings.dart';
import '../theme.dart';

/// Setting up a monthly bill.
///
/// Longer than the expense flow on purpose — this is done once and then never
/// again, so it can afford to ask properly. The daily entry flow is the one
/// that has to be two taps.
class TemplateEditorScreen extends StatefulWidget {
  const TemplateEditorScreen({this.existing, super.key});

  final DueTemplate? existing;

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _amount = TextEditingController();

  RecurringKind _kind = RecurringKind.expense;
  AccountRow? _category;
  AccountRow? _source;
  int _day = 1;
  bool _variableAmount = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final DueTemplate? existing = widget.existing;
    if (existing != null) {
      _kind = existing.template.kind;
      _category = existing.category;
      _source = existing.source;
      _day = existing.template.dayOfMonth;
      _variableAmount = existing.isVariableAmount;
      _name.text = existing.template.description;
      if (!existing.isVariableAmount) {
        _amount.text = (existing.amount.paisa ~/ Money.paisaPerRupee).toString();
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final S s = AppScope.stringsOf(context);
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ledger = AppScope.ledgerRead(context);

    if (_category == null || _source == null || _name.text.trim().isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(s.enterAmount)));
      return;
    }

    final Money amount = _variableAmount
        ? Money.zero
        : (Money.tryParse(_amount.text) ?? Money.zero);
    if (!_variableAmount && !amount.isPositive) {
      messenger.showSnackBar(SnackBar(content: Text(s.enterAmount)));
      return;
    }

    setState(() => _saving = true);
    try {
      await ledger.saveTemplate(
        id: widget.existing?.template.id,
        kind: _kind,
        categoryAccountId: _category!.id,
        sourceAccountId: _source!.id,
        amount: amount,
        description: _name.text.trim(),
        dayOfMonth: _day,
      );
      navigator.pop(true);
    } on LedgerValidationError catch (error) {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.monthlyBills)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: s.nameIt,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          _Label(s.chooseCategory),
          _AccountPicker(
            type: _kind == RecurringKind.expense
                ? AccountType.expense
                : AccountType.income,
            selected: _category,
            onChanged: (AccountRow value) =>
                setState(() => _category = value),
          ),

          const SizedBox(height: 20),
          _Label(_kind == RecurringKind.expense ? s.paidFrom : s.receivedIn),
          _AccountPicker(
            type: AccountType.asset,
            selected: _source,
            onChanged: (AccountRow value) => setState(() => _source = value),
          ),

          const SizedBox(height: 20),
          _Label(s.amountEveryMonth),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _variableAmount,
            title: Text(s.amountVaries, style: theme.textTheme.bodyLarge),
            subtitle: Text(s.amountVariesHelp,
                style: theme.textTheme.bodySmall),
            onChanged: (bool value) =>
                setState(() => _variableAmount = value),
          ),
          if (!_variableAmount)
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: 'Rs ',
                border: OutlineInputBorder(),
              ),
            ),

          const SizedBox(height: 22),
          _Label(s.whichDay),
          _DayPicker(
            selected: _day,
            onChanged: (int value) => setState(() => _day = value),
          ),

          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(s.save),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

class _AccountPicker extends StatelessWidget {
  const _AccountPicker({
    required this.type,
    required this.selected,
    required this.onChanged,
  });

  final AccountType type;
  final AccountRow? selected;
  final ValueChanged<AccountRow> onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AccountBalance>>(
      stream: AppScope.ledgerOf(context).watchAccountBalances(type: type),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<AccountBalance>> snapshot,
      ) {
        final List<AccountBalance> accounts =
            snapshot.data ?? const <AccountBalance>[];
        if (accounts.isEmpty) return const SizedBox.shrink();

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final AccountBalance account in accounts)
              ChoiceChip(
                avatar: Icon(
                  iconForKey(account.account.iconKey),
                  size: 18,
                  color: colorForIcon(account.account.iconKey),
                ),
                label: Text(
                  AppScope.stringsOf(context).accountName(account.account),
                ),
                selected: selected?.id == account.id,
                onSelected: (_) => onChanged(account.account),
              ),
          ],
        );
      },
    );
  }
}

/// Days 1 to 31 as a grid.
///
/// A calendar widget would be the obvious choice and the wrong one: this is a
/// day-of-month, not a date, and Material's picker would drag English month
/// names onto a screen the app deliberately keeps in Urdu.
class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: <Widget>[
          for (int day = 1; day <= 31; day++)
            SizedBox(
              width: 44,
              height: 44,
              child: Material(
                color: day == selected ? AppTheme.primary : AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onChanged(day),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: day == selected ? Colors.white : AppTheme.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
