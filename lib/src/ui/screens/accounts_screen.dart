import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../domain/account_type.dart';
import '../../domain/models.dart';
import '../app_scope.dart';
import '../category_icons.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/money_text.dart';

/// Where the household's money sits: نقد, بینک, بچت.
///
/// Reached by tapping the balance on the home screen, because that is where
/// the question comes from — you look at the total and want to know what makes
/// it up, or to correct it.
///
/// Correcting a balance does not rewrite anything. It records the difference
/// as an adjustment on today's date, so the ledger keeps saying what it always
/// said and gains an honest note about when the two stopped agreeing.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.myMoney)),
      body: StreamBuilder<List<AccountBalance>>(
        stream: AppScope.ledgerOf(context)
            .watchAccountBalances(type: AccountType.asset),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<AccountBalance>> snapshot,
        ) {
          final List<AccountBalance> accounts =
              snapshot.data ?? const <AccountBalance>[];
          if (accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          Money total = Money.zero;
          for (final AccountBalance account in accounts) {
            total = total + account.displayBalance;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: <Widget>[
              Text(s.myMoneyHelp, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              for (final AccountBalance account in accounts)
                _AccountRow(account: account),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(s.total, style: theme.textTheme.titleMedium),
                    MoneyText(
                      total,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.account});

  final AccountBalance account;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);
    final Color accent = colorForIcon(account.account.iconKey);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 23,
          backgroundColor: accent.withValues(alpha: 0.14),
          child: Icon(iconForKey(account.account.iconKey),
              color: accent, size: 23),
        ),
        title: Text(
          s.accountName(account.account),
          style: theme.textTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(s.tapToCorrect, style: theme.textTheme.bodySmall),
        trailing: MoneyText(
          account.displayBalance,
          style: theme.textTheme.titleMedium,
        ),
        onTap: () => _edit(context, s),
      ),
    );
  }

  Future<void> _edit(BuildContext context, S s) async {
    final ledger = AppScope.ledgerRead(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final Money? updated = await showModalBottomSheet<Money>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => _BalanceSheet(
        title: s.accountName(account.account),
        current: account.displayBalance,
      ),
    );

    if (updated == null) return;
    await ledger.setAccountBalance(
      accountId: account.id,
      actual: updated,
    );
    messenger.showSnackBar(SnackBar(content: Text(s.saved)));
  }
}

/// Asks what the account really holds right now.
class _BalanceSheet extends StatefulWidget {
  const _BalanceSheet({required this.title, required this.current});

  final String title;
  final Money current;

  @override
  State<_BalanceSheet> createState() => _BalanceSheetState();
}

class _BalanceSheetState extends State<_BalanceSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.current.isZero
          ? ''
          : (widget.current.paisa ~/ Money.paisaPerRupee).toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(s.howMuchInAccount, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: 'Rs ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text(s.correctionNote, style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final Money? amount = Money.tryParse(_controller.text);
                if (amount == null) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.of(context).pop(amount);
              },
              child: Text(s.save),
            ),
          ),
        ],
      ),
    );
  }
}
