import 'package:flutter/material.dart';

import 'core/money.dart';
import 'domain/account_type.dart';
import 'domain/chart_of_accounts.dart';
import 'domain/models.dart';
import 'engine.dart';

/// A plain screen for checking that the Stage 0 engine works on a real device.
///
/// Deliberately unstyled — Stage 1 replaces this entirely with the Urdu-first
/// interface. Its only job is to make the invisible parts visible: are the
/// categories seeded, do balances update the instant something is written,
/// does the ledger refuse to accept a broken entry.
class DevHomePage extends StatelessWidget {
  const DevHomePage({required this.engine, super.key});

  final GharSaheliEngine engine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghar Saheli — engine check'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'device ${engine.deviceId.substring(0, 8)}…',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _NetCashCard(engine: engine),
          const SizedBox(height: 16),
          _Actions(engine: engine),
          const SizedBox(height: 24),
          const _SectionTitle('Recent entries'),
          _RecentEntries(engine: engine),
          const SizedBox(height: 24),
          const _SectionTitle('Balances'),
          _Balances(engine: engine),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _NetCashCard extends StatelessWidget {
  const _NetCashCard({required this.engine});

  final GharSaheliEngine engine;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Money on hand'),
            const SizedBox(height: 4),
            StreamBuilder<Money>(
              stream: engine.ledger.watchNetCash(),
              builder: (BuildContext context, AsyncSnapshot<Money> snapshot) {
                final Money value = snapshot.data ?? Money.zero;
                return Text(
                  value.format(),
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: engine.ledger.watchEventCount(),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                return Text(
                  '${snapshot.data ?? 0} events in the log',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.engine});

  final GharSaheliEngine engine;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
    String okMessage,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(okMessage)));
    } on LedgerValidationError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        FilledButton(
          onPressed: () => _run(
            context,
            () => engine.ledger.setOpeningBalance(
              accountId: AccountCodes.idOf(AccountCodes.cash),
              amount: Money.rupees(50000),
            ),
            'Opening balance Rs 50,000 added to cash',
          ),
          child: const Text('Opening Rs 50,000'),
        ),
        FilledButton.tonal(
          onPressed: () => _run(
            context,
            () => engine.ledger.recordExpense(
              expenseAccountId: AccountCodes.idOf('expense.groceries'),
              paidFromAccountId: AccountCodes.idOf(AccountCodes.cash),
              amount: Money.rupees(2500),
              description: 'Raashan',
            ),
            'Rs 2,500 groceries recorded',
          ),
          child: const Text('Spend Rs 2,500'),
        ),
        FilledButton.tonal(
          onPressed: () => _run(
            context,
            () => engine.ledger.recordIncome(
              incomeAccountId: AccountCodes.idOf('income.salary'),
              receivedIntoAccountId: AccountCodes.idOf(AccountCodes.bank),
              amount: Money.rupees(120000),
              description: 'Salary',
            ),
            'Rs 1,20,000 salary recorded',
          ),
          child: const Text('Salary Rs 1,20,000'),
        ),
        OutlinedButton(
          onPressed: () => _selfCheck(context),
          child: const Text('Run self-check'),
        ),
      ],
    );
  }

  /// Proves the guarantees the rest of the app is going to rely on.
  Future<void> _selfCheck(BuildContext context) async {
    final List<String> results = <String>[];

    // 1. An unbalanced entry must be refused.
    try {
      await engine.ledger.recordEntry(
        DraftEntry(
          description: 'Broken on purpose',
          postings: <DraftPosting>[
            DraftPosting(
              accountId: AccountCodes.idOf(AccountCodes.cash),
              amount: Money.rupees(100),
            ),
            DraftPosting(
              accountId: AccountCodes.idOf('expense.other'),
              amount: Money.rupees(-90),
            ),
          ],
        ),
      );
      results.add('FAIL — unbalanced entry was accepted');
    } on LedgerValidationError {
      results.add('OK — unbalanced entry refused');
    }

    // 2. South Asian digit grouping.
    final String grouped = Money.rupees(12345678).format(symbol: false);
    results.add(
      grouped == '1,23,45,678'
          ? 'OK — grouping reads $grouped'
          : 'FAIL — grouping gave $grouped',
    );

    // 3. Typed input survives commas, symbols and Urdu digits.
    final Money? parsed = Money.tryParse('Rs 1,250.50');
    results.add(
      parsed?.paisa == 125050
          ? 'OK — parsed Rs 1,250.50'
          : 'FAIL — parsed ${parsed?.paisa}',
    );

    // 4. Seeded categories are present.
    final List<AccountBalance> expenses = await engine.ledger.accountBalances(
      type: AccountType.expense,
    );
    results.add(
      expenses.length >= 10
          ? 'OK — ${expenses.length} expense categories seeded'
          : 'FAIL — only ${expenses.length} categories',
    );

    // 5. Voiding leaves the entry in place but removes it from balances.
    final Money before = await engine.ledger.balanceOf(
      AccountCodes.idOf(AccountCodes.cash),
    );
    final String entryId = await engine.ledger.recordExpense(
      expenseAccountId: AccountCodes.idOf('expense.other'),
      paidFromAccountId: AccountCodes.idOf(AccountCodes.cash),
      amount: Money.rupees(999),
      description: 'Self-check entry',
    );
    await engine.ledger.voidEntry(entryId);
    final Money after = await engine.ledger.balanceOf(
      AccountCodes.idOf(AccountCodes.cash),
    );
    results.add(
      before == after
          ? 'OK — voided entry left balance untouched'
          : 'FAIL — balance moved ${(after - before).format()}',
    );

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Engine self-check'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final String line in results)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(line),
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _RecentEntries extends StatelessWidget {
  const _RecentEntries({required this.engine});

  final GharSaheliEngine engine;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EntryWithPostings>>(
      stream: engine.ledger.watchEntries(limit: 15),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<EntryWithPostings>> snapshot,
      ) {
        final List<EntryWithPostings> entries =
            snapshot.data ?? const <EntryWithPostings>[];
        if (entries.isEmpty) {
          return const Text('Nothing recorded yet.');
        }
        return Column(
          children: <Widget>[
            for (final EntryWithPostings entry in entries)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(entry.entry.description),
                subtitle: Text(
                  '${entry.occurredOn.day}/${entry.occurredOn.month} · '
                  '${entry.primaryLine?.account.nameUr ?? ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(entry.magnitude.format()),
                    IconButton(
                      icon: const Icon(Icons.undo, size: 18),
                      tooltip: 'Void',
                      onPressed: () => engine.ledger.voidEntry(entry.id),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Balances extends StatelessWidget {
  const _Balances({required this.engine});

  final GharSaheliEngine engine;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AccountBalance>>(
      stream: engine.ledger.watchAccountBalances(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<AccountBalance>> snapshot,
      ) {
        final List<AccountBalance> accounts =
            snapshot.data ?? const <AccountBalance>[];
        if (accounts.isEmpty) {
          return const Text('Seeding…');
        }
        return Column(
          children: <Widget>[
            for (final AccountBalance account in accounts)
              if (!account.rawBalance.isZero ||
                  account.type == AccountType.asset)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(account.account.name),
                  subtitle: Text(
                    '${account.account.nameUr} · ${account.type.name}',
                  ),
                  trailing: Text(account.displayBalance.format()),
                ),
          ],
        );
      },
    );
  }
}
