import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../domain/models.dart';
import '../../domain/staff.dart';
import '../app_scope.dart';
import '../strings.dart';

/// Adding or editing a staff member.
class StaffEditorScreen extends StatefulWidget {
  const StaffEditorScreen({this.existing, super.key});

  final StaffWithAccounts? existing;

  @override
  State<StaffEditorScreen> createState() => _StaffEditorScreenState();
}

class _StaffEditorScreenState extends State<StaffEditorScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _salary = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final StaffWithAccounts? existing = widget.existing;
    if (existing != null) {
      _name.text = existing.name;
      _salary.text =
          (existing.monthlySalary.paisa ~/ Money.paisaPerRupee).toString();
      _phone.text = existing.staff.phone ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _salary.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final S s = AppScope.stringsOf(context);
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ledger = AppScope.ledgerRead(context);

    final Money salary = Money.tryParse(_salary.text) ?? Money.zero;
    if (_name.text.trim().isEmpty || !salary.isPositive) {
      messenger.showSnackBar(SnackBar(content: Text(s.enterAmount)));
      return;
    }

    setState(() => _saving = true);
    try {
      final StaffWithAccounts? existing = widget.existing;
      if (existing == null) {
        await ledger.addStaff(
          name: _name.text,
          monthlySalary: salary,
          phone: _phone.text.trim().isEmpty ? null : _phone.text,
        );
      } else {
        await ledger.updateStaff(
          existing: existing,
          name: _name.text,
          monthlySalary: salary,
          phone: _phone.text.trim().isEmpty ? null : _phone.text,
        );
      }
      navigator.pop(true);
    } on LedgerValidationError catch (error) {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? s.addStaff : s.staff),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: s.staffName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _salary,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: s.monthlySalary,
              prefixText: 'Rs ',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: s.phoneOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(s.save),
          ),
        ],
      ),
    );
  }
}
