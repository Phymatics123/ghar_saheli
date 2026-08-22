import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../domain/chart_of_accounts.dart';
import '../../domain/tariffs.dart';
import '../app_scope.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/money_text.dart';

/// Works out roughly what an electricity bill will come to.
///
/// The point is not to replace the bill — it is to answer the question people
/// actually ask, which is "if the meter says this many units, how bad is it
/// going to be". Slab tariffs are hard to do in your head because each band is
/// charged separately, and getting it wrong by a band is the difference between
/// planning for Rs 8,000 and being handed Rs 14,000.
class BillCalculatorScreen extends StatefulWidget {
  const BillCalculatorScreen({super.key});

  @override
  State<BillCalculatorScreen> createState() => _BillCalculatorScreenState();
}

class _BillCalculatorScreenState extends State<BillCalculatorScreen> {
  final TextEditingController _units = TextEditingController(text: '300');
  final TextEditingController _fuel = TextEditingController();
  final TextEditingController _quarterly = TextEditingController();
  final TextEditingController _meterRent = TextEditingController();

  ElectricityTariff _tariff = kElectricityTariffs.first;
  bool _isProtected = false;

  @override
  void dispose() {
    _units.dispose();
    _fuel.dispose();
    _quarterly.dispose();
    _meterRent.dispose();
    super.dispose();
  }

  BillEstimate get _estimate => estimateBill(
        tariff: _tariff,
        units: int.tryParse(_units.text) ?? 0,
        isProtected: _isProtected,
        fuelAdjustment: Money.tryParse(_fuel.text) ?? Money.zero,
        quarterlyAdjustment: Money.tryParse(_quarterly.text) ?? Money.zero,
        meterRent: Money.tryParse(_meterRent.text) ?? Money.zero,
      );

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);
    final BillEstimate estimate = _estimate;

    return Scaffold(
      appBar: AppBar(title: Text(s.billCalculator)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: <Widget>[
          Text(s.billCalculatorHelp, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),

          Text(s.company, style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final ElectricityTariff tariff in kElectricityTariffs)
                ChoiceChip(
                  label: Text(
                    AppScope.settingsOf(context).language == AppLanguage.urdu
                        ? tariff.nameUr
                        : tariff.name,
                  ),
                  selected: _tariff.id == tariff.id,
                  onSelected: (_) => setState(() => _tariff = tariff),
                ),
            ],
          ),

          const SizedBox(height: 18),
          TextField(
            controller: _units,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: s.unitsUsed,
              border: const OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _isProtected,
            title: Text(s.protectedCustomer, style: theme.textTheme.bodyLarge),
            subtitle: Text(s.protectedHelp, style: theme.textTheme.bodySmall),
            onChanged: (bool value) => setState(() => _isProtected = value),
          ),

          const SizedBox(height: 12),
          Text(s.extrasFromBill, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(child: _extraField(_fuel, s.fuelAdjustment)),
              const SizedBox(width: 10),
              Expanded(child: _extraField(_quarterly, s.quarterlyAdjustment)),
            ],
          ),
          const SizedBox(height: 10),
          _extraField(_meterRent, s.meterRent),

          const SizedBox(height: 24),
          _EstimateCard(estimate: estimate),

          const SizedBox(height: 14),
          // Stated plainly and left on screen. The slabs bundled with the app
          // were correct when written and NEPRA revises them without warning;
          // a confident wrong number would be worse than no calculator at all.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.info_outline,
                    size: 18, color: Color(0xFFB26A00)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.estimateWarning,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.add),
            label: Text(s.recordAsExpense),
            onPressed: estimate.total.isPositive
                ? () => _record(context, s, estimate)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _extraField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'Rs ',
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<void> _record(
    BuildContext context,
    S s,
    BillEstimate estimate,
  ) async {
    final ledger = AppScope.ledgerRead(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);

    await ledger.recordExpense(
      expenseAccountId: AccountCodes.idOf('expense.electricity'),
      paidFromAccountId: AccountCodes.idOf(AccountCodes.cash),
      amount: estimate.total,
      description: '${_tariff.name} — ${estimate.units} units',
    );
    messenger.showSnackBar(SnackBar(content: Text(s.saved)));
    navigator.pop();
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.estimate});

  final BillEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Each band shown separately, because the whole reason a slab bill
            // surprises people is that they assume one rate applies to
            // everything.
            for (final SlabCharge charge in estimate.charges)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${charge.fromUnit}–${charge.toUnit}  ×  '
                        'Rs ${charge.rupeesPerUnit.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      MoneyText(charge.amount,
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            const Divider(height: 18),
            _line(context, s.energyCharge, estimate.energyCharge),
            if (estimate.fuelAdjustment.isPositive)
              _line(context, s.fuelAdjustment, estimate.fuelAdjustment),
            if (estimate.quarterlyAdjustment.isPositive)
              _line(context, s.quarterlyAdjustment,
                  estimate.quarterlyAdjustment),
            if (estimate.meterRent.isPositive)
              _line(context, s.meterRent, estimate.meterRent),
            _line(
              context,
              '${s.salesTax} ${estimate.salesTaxPercent.toStringAsFixed(0)}%',
              estimate.salesTax,
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(s.estimatedTotal, style: theme.textTheme.titleMedium),
                MoneyText(
                  estimate.total,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: AppTheme.spend),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, String label, Money amount) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(label,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          MoneyText(amount, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
