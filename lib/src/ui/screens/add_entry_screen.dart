import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/database.dart';
import '../../domain/account_type.dart';
import '../../domain/chart_of_accounts.dart';
import '../../domain/models.dart';
import '../../domain/recurring.dart';
import '../app_scope.dart';
import '../category_icons.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/money_text.dart';
import '../widgets/numeric_keypad.dart';
import 'staff_screen.dart';

enum EntryKind { expense, income }

/// Recording money moving.
///
/// Two steps, in a fixed order: pick the category, then type the amount. Never
/// a form with several fields to fill in any order. Guided linear flows test
/// far better with users who are not confident with phones — there is only ever
/// one thing to do next, and no way to be halfway through and stuck.
///
/// Everything else has a sensible default already chosen: today's date, and
/// cash as the source. A user who does not care never has to look at them.
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({
    required this.kind,
    this.preselected,
    this.confirmingTemplate,
    super.key,
  });

  final EntryKind kind;

  /// Set when the user came from a category tile on the home screen, which
  /// skips step one entirely and makes this a two-tap flow.
  final AccountRow? preselected;

  /// Set when this is confirming a monthly bill whose amount changes each
  /// time. Saving then also stamps the template done for the month, so it
  /// stops being offered.
  final DueTemplate? confirmingTemplate;

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  AccountRow? _category;
  AccountRow? _source;
  String _digits = '';
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _category = widget.preselected;
    final DateTime now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
  }

  Money get _amount =>
      _digits.isEmpty ? Money.zero : Money.rupees(int.parse(_digits));

  bool get _isExpense => widget.kind == EntryKind.expense;

  void _appendDigit(String digit) {
    // Nine digits is Rs 99 crore — past any household figure, and past the
    // point the number still fits on screen.
    if (_digits.length + digit.length > 9) return;
    if (_digits.isEmpty && digit == '00') return;
    setState(() => _digits = (_digits + digit).replaceFirst(RegExp(r'^0+'), ''));
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  Future<void> _save() async {
    final S s = AppScope.stringsOf(context);
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    if (_amount.isZero || _category == null || _source == null) {
      messenger.showSnackBar(SnackBar(content: Text(s.enterAmount)));
      return;
    }

    setState(() => _saving = true);
    try {
      final ledger = AppScope.ledgerRead(context);

      // Confirming a monthly bill goes through the repository so the ledger
      // entry and the month stamp happen as one operation, in that order.
      final DueTemplate? template = widget.confirmingTemplate;
      if (template != null) {
        await ledger.confirmTemplate(
          due: template,
          amount: _amount,
          on: _date,
        );
        navigator.pop(true);
        return;
      }

      if (_isExpense) {
        await ledger.recordExpense(
          expenseAccountId: _category!.id,
          paidFromAccountId: _source!.id,
          amount: _amount,
          // The language-aware name, not `.name` (always English regardless
          // of the app's language) or `.nameUr` (always Urdu script even in
          // Roman/English mode). This is the text stored permanently in the
          // ledger, so getting it wrong here shows up anywhere the raw
          // description is read back, in whatever language it was saved.
          description: s.accountName(_category!),
          on: _date,
        );
      } else {
        await ledger.recordIncome(
          incomeAccountId: _category!.id,
          receivedIntoAccountId: _source!.id,
          amount: _amount,
          // The language-aware name, not `.name` (always English regardless
          // of the app's language) or `.nameUr` (always Urdu script even in
          // Roman/English mode). This is the text stored permanently in the
          // ledger, so getting it wrong here shows up anywhere the raw
          // description is read back, in whatever language it was saved.
          description: s.accountName(_category!),
          on: _date,
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
        title: Text(_isExpense ? s.addExpense : s.addIncome),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Step back within the flow before leaving it.
            if (_category != null && widget.preselected == null) {
              setState(() => _category = null);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _category == null ? _buildCategoryStep(s) : _buildAmountStep(s),
    );
  }

  /// Picking a category, with one exception.
  ///
  /// ملازمین is not a category you type an amount against — a staff payment
  /// has attendance behind it and a peshgi to settle, and recording it as a
  /// loose expense would quietly bypass both and leave the person's advance
  /// showing as still owed. Tapping it goes to the staff screen instead, which
  /// is where that money is actually handled.
  Future<void> _chooseCategory(AccountRow account) async {
    if (account.code == AccountCodes.staff) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const StaffScreen()),
      );
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _category = account);
  }

  // ---- Step one: what was it for ----

  Widget _buildCategoryStep(S s) {
    final AccountType type =
        _isExpense ? AccountType.expense : AccountType.income;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Text(
            _isExpense ? s.chooseCategory : s.chooseIncomeSource,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: StreamBuilder<List<AccountBalance>>(
            stream: AppScope.ledgerOf(context).watchAccountBalances(type: type),
            builder: (
              BuildContext context,
              AsyncSnapshot<List<AccountBalance>> snapshot,
            ) {
              final List<AccountBalance> accounts =
                  snapshot.data ?? const <AccountBalance>[];
              if (accounts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  // 0.92 was tuned against short English labels and had no
                  // margin left for a two-line wrap. Longer labels — "Bachon
                  // ki fees", "Mehmaan nawazi", and Urdu script's taller line
                  // height — pushed the tile past its own height by a few
                  // pixels. 0.74 leaves real headroom for the longest label in
                  // any of the three languages, not just the ones tested.
                  childAspectRatio: 0.74,
                ),
                itemCount: accounts.length,
                itemBuilder: (BuildContext context, int index) {
                  final AccountRow account = accounts[index].account;
                  return _CategoryTile(
                    account: account,
                    onTap: () => _chooseCategory(account),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ---- Step two: how much ----

  Widget _buildAmountStep(S s) {
    final AccountRow category = _category!;
    final ThemeData theme = Theme.of(context);
    final Color accent = colorForIcon(category.iconKey);

    return Column(
      children: <Widget>[
        // Everything above the keypad scrolls.
        //
        // It used to be a fixed column ending in a Spacer, which works only
        // while the content fits. A category with spending history shows an
        // extra row of remembered amounts, and on a shorter screen that tipped
        // the total past the available height — a Spacer can shrink to nothing
        // but no further, so the rest overflowed. Making this region flexible
        // means the layout holds whatever appears in it, on any screen.
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // The chosen category stays visible and stays tappable, so a
                // wrong pick costs one tap to fix rather than a trip back.
                InkWell(
          onTap: widget.preselected != null
              ? null
              : () => setState(() => _category = null),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 22,
                  backgroundColor: accent.withValues(alpha: 0.15),
                  child: Icon(iconForKey(category.iconKey),
                      color: accent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppScope.stringsOf(context).accountName(category),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (widget.preselected == null)
                  const Icon(Icons.edit, size: 18, color: AppTheme.inkSoft),
              ],
            ),
          ),
        ),

        Text(s.howMuch, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        MoneyText(
          _amount,
          // The figure being typed right now. Masking this would make the
          // keypad unusable rather than private.
          alwaysVisible: true,
          style: theme.textTheme.displayLarge?.copyWith(
            color: _digits.isEmpty
                ? AppTheme.inkSoft
                : (_isExpense ? AppTheme.spend : AppTheme.earn),
          ),
        ),
        const SizedBox(height: 8),

        _RecentAmounts(
          accountId: category.id,
          onPick: (Money amount) => setState(
            () => _digits = (amount.paisa ~/ Money.paisaPerRupee).toString(),
          ),
        ),
        const SizedBox(height: 8),

        _DateChips(
          selected: _date,
          onChanged: (DateTime value) => setState(() => _date = value),
        ),
        const SizedBox(height: 10),
                _SourceChips(
                  isExpense: _isExpense,
                  selected: _source,
                  onChanged: (AccountRow value) =>
                      setState(() => _source = value),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Keypad and save stay pinned to the bottom, always reachable.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: NumericKeypad(
            onDigit: _appendDigit,
            onBackspace: _backspace,
            onBackspaceLongPress: () => setState(() => _digits = ''),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving || _amount.isZero ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: _isExpense ? AppTheme.spend : AppTheme.earn,
              ),
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(s.save),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.account, required this.onTap});

  final AccountRow account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = colorForIcon(account.iconKey);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconForKey(account.iconKey),
                      color: accent, size: 27),
                ),
                const SizedBox(height: 8),
                Text(
                  AppScope.stringsOf(context).accountName(account),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What was last paid for this category, as tappable chips.
///
/// The household buys the same things for roughly the same money week after
/// week, so the fastest amount to enter is usually one already entered before.
/// This is memory, not prediction — every figure here is one the user typed
/// themselves, which is also why it needs no model, no network and no guessing.
///
/// A `FutureBuilder` rather than a stream: these only need to be right when the
/// screen opens, and re-querying on every keystroke would be work for nothing.
class _RecentAmounts extends StatefulWidget {
  const _RecentAmounts({required this.accountId, required this.onPick});

  final String accountId;
  final ValueChanged<Money> onPick;

  @override
  State<_RecentAmounts> createState() => _RecentAmountsState();
}

class _RecentAmountsState extends State<_RecentAmounts> {
  late Future<List<Money>> _amounts;

  // Reading the scope here rather than in initState. Flutter forbids taking an
  // inherited-widget dependency before initState has finished, and doing it
  // anyway left a dependency that was never cleaned up when this widget went
  // away — the leak behind the `_dependents.isEmpty` crash.
  @override
  void initState() {
    super.initState();
    _amounts = AppScope.ledgerRead(context).recentAmountsFor(widget.accountId);
  }

  @override
  void didUpdateWidget(_RecentAmounts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountId != widget.accountId) {
      _amounts =
          AppScope.ledgerRead(context).recentAmountsFor(widget.accountId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);

    return FutureBuilder<List<Money>>(
      future: _amounts,
      builder: (BuildContext context, AsyncSnapshot<List<Money>> snapshot) {
        final List<Money> amounts = snapshot.data ?? const <Money>[];
        if (amounts.isEmpty) return const SizedBox.shrink();

        return Column(
          children: <Widget>[
            Text(s.lastTime, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final Money amount in amounts)
                  ActionChip(
                    label: MoneyText(
                      amount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onPressed: () => widget.onPick(amount),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Today, yesterday, the day before.
///
/// No calendar. People enter shopping the same day or the next morning, and a
/// full date picker would drag in Material's English month names — exactly the
/// English this app is trying to keep off the screen. A proper Urdu calendar
/// can come when there is evidence anyone needs to backdate further.
class _DateChips extends StatelessWidget {
  const _DateChips({required this.selected, required this.onChanged});

  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final List<(String, DateTime)> options = <(String, DateTime)>[
      (s.today, today),
      (s.yesterday, today.subtract(const Duration(days: 1))),
      (s.dayBefore, today.subtract(const Duration(days: 2))),
    ];

    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final (String label, DateTime date) in options)
          ChoiceChip(
            label: Text(label),
            selected: selected == date,
            onSelected: (_) => onChanged(date),
          ),
      ],
    );
  }
}

/// Which pocket the money came from or went into.
class _SourceChips extends StatelessWidget {
  const _SourceChips({
    required this.isExpense,
    required this.selected,
    required this.onChanged,
  });

  final bool isExpense;
  final AccountRow? selected;
  final ValueChanged<AccountRow> onChanged;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);

    return StreamBuilder<List<AccountBalance>>(
      stream: AppScope.ledgerOf(context)
          .watchAccountBalances(type: AccountType.asset),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<AccountBalance>> snapshot,
      ) {
        final List<AccountBalance> accounts =
            snapshot.data ?? const <AccountBalance>[];
        if (accounts.isEmpty) return const SizedBox.shrink();

        // Cash first and pre-chosen. Most household spending is cash, so the
        // common case should need no decision at all.
        if (selected == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) onChanged(accounts.first.account);
          });
        }

        return Column(
          children: <Widget>[
            Text(
              isExpense ? s.paidFrom : s.receivedIn,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final AccountBalance account in accounts)
                  ChoiceChip(
                    avatar: Icon(
                      iconForKey(account.account.iconKey),
                      size: 18,
                      color: colorForIcon(account.account.iconKey),
                    ),
                    label: Text(s.accountName(account.account)),
                    selected: selected?.id == account.id,
                    onSelected: (_) => onChanged(account.account),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
