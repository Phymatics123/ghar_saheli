import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/database.dart';
import '../../domain/account_type.dart';
import '../../domain/models.dart';
import '../../domain/recurring.dart';
import '../../domain/staff.dart';
import '../../services/receipt_pdf.dart';
import '../app_scope.dart';
import '../category_icons.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/money_text.dart';
import 'staff_editor_screen.dart';

/// One staff member: their register, their peshgi, and their pay.
class StaffDetailScreen extends StatefulWidget {
  const StaffDetailScreen({required this.staffId, super.key});

  final String staffId;

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);

    return StreamBuilder<List<StaffWithAccounts>>(
      stream: AppScope.ledgerOf(context).watchStaff(onlyActive: false),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<StaffWithAccounts>> snapshot,
      ) {
        final List<StaffWithAccounts> all =
            snapshot.data ?? const <StaffWithAccounts>[];
        StaffWithAccounts? member;
        for (final StaffWithAccounts candidate in all) {
          if (candidate.id == widget.staffId) member = candidate;
        }

        if (member == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final StaffWithAccounts staff = member;

        return Scaffold(
          appBar: AppBar(
            title: Text(staff.name),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StaffEditorScreen(existing: staff),
                  ),
                ),
              ),
            ],
          ),
          body: StreamBuilder<List<StaffAttendanceRow>>(
            stream: AppScope.ledgerOf(context)
                .watchAttendance(staffId: staff.id, month: _month),
            builder: (
              BuildContext context,
              AsyncSnapshot<List<StaffAttendanceRow>> attendanceSnapshot,
            ) {
              final List<StaffAttendanceRow> attendance =
                  attendanceSnapshot.data ?? const <StaffAttendanceRow>[];

              final SalaryCalculation calculation = SalaryCalculation.compute(
                month: _month,
                monthlySalary: staff.monthlySalary,
                attendance: attendance,
                outstandingAdvance: staff.outstandingAdvance,
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: <Widget>[
                  _PeshgiCard(member: staff),
                  const SizedBox(height: 18),
                  _MonthHeader(
                    month: _month,
                    onPrevious: () => _shiftMonth(-1),
                    onNext: () => _shiftMonth(1),
                  ),
                  const SizedBox(height: 10),
                  _AttendanceGrid(
                    staffId: staff.id,
                    month: _month,
                    attendance: attendance,
                  ),
                  const SizedBox(height: 10),
                  const _AttendanceLegend(),
                  const SizedBox(height: 20),
                  _SalaryCard(
                    member: staff,
                    calculation: calculation,
                    month: _month,
                  ),
                  const SizedBox(height: 22),
                  TextButton.icon(
                    icon: const Icon(Icons.person_off_outlined, size: 18),
                    label: Text(s.removeStaff),
                    style: TextButton.styleFrom(
                        foregroundColor: AppTheme.inkSoft),
                    onPressed: () => _confirmRemove(context, s, staff),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    S s,
    StaffWithAccounts member,
  ) async {
    final ledger = AppScope.ledgerRead(context);
    final NavigatorState navigator = Navigator.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(member.name),
        content: Text(s.removeStaff),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(s.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ledger.deactivateStaff(member.id);
      navigator.pop();
    }
  }
}

class _PeshgiCard extends StatelessWidget {
  const _PeshgiCard({required this.member});

  final StaffWithAccounts member;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);
    final bool owes = member.outstandingAdvance.isPositive;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: owes ? const Color(0xFFFFF6E5) : AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: owes ? const Color(0xFFE3B778) : AppTheme.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.outstandingPeshgi,
                        style: theme.textTheme.bodySmall),
                    MoneyText(
                      member.outstandingAdvance,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: owes ? const Color(0xFFB26A00) : AppTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () => _giveAdvance(context, s),
                child: Text(s.givePeshgi),
              ),
            ],
          ),
          if (owes) ...<Widget>[
            const SizedBox(height: 6),
            Text(s.peshgiHelp, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Future<void> _giveAdvance(BuildContext context, S s) async {
    final ledger = AppScope.ledgerRead(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final _AmountAndSource? result = await showModalBottomSheet<_AmountAndSource>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) =>
          _AmountSheet(title: s.givePeshgi, confirmLabel: s.save),
    );

    if (result == null) return;
    await ledger.giveAdvance(
      member: member,
      amount: result.amount,
      paidFromAccountId: result.sourceId,
    );
    messenger.showSnackBar(SnackBar(content: Text(s.saved)));
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrevious,
        ),
        Expanded(
          child: Text(
            '${s.monthName(month.month)} ${month.year}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// The month's register as a grid of days.
///
/// Marking a month used to mean cycling each day through five states — two
/// taps for an absence, four for leave, and thirty-plus taps for an ordinary
/// month where someone simply turned up every day.
///
/// Now the common case is the cheap one. **Mark all present** fills the month
/// to today in a single tap, a **tap** toggles one day present or blank, and
/// the rarer answers — absent, half day, leave — are behind a **hold**. Most
/// months become one tap plus a correction or two.
class _AttendanceGrid extends StatelessWidget {
  const _AttendanceGrid({
    required this.staffId,
    required this.month,
    required this.attendance,
  });

  final String staffId;
  final DateTime month;
  final List<StaffAttendanceRow> attendance;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final Map<int, AttendanceStatus> byDay = <int, AttendanceStatus>{
      for (final StaffAttendanceRow row in attendance)
        row.onDate.day: row.status,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                s.attendanceHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(s.allPresent),
              onPressed: () => _markAllPresent(context, s),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (int day = 1; day <= daysInMonth(month); day++)
                _DayCell(
                  day: day,
                  status: byDay[day],
                  onTap: () => _toggle(context, day, byDay[day]),
                  onLongPress: () => _choose(context, s, day),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// One tap: present, or back to blank if it already said present.
  Future<void> _toggle(
    BuildContext context,
    int day,
    AttendanceStatus? current,
  ) async {
    final ledger = AppScope.ledgerRead(context);
    final DateTime date = DateTime(month.year, month.month, day);

    if (current == AttendanceStatus.present) {
      await ledger.clearAttendance(staffId: staffId, date: date);
    } else {
      await ledger.markAttendance(
        staffId: staffId,
        date: date,
        status: AttendanceStatus.present,
      );
    }
  }

  /// Hold: everything else, in one screen rather than several taps.
  Future<void> _choose(BuildContext context, S s, int day) async {
    final ledger = AppScope.ledgerRead(context);
    final DateTime date = DateTime(month.year, month.month, day);

    final List<(AttendanceStatus?, String)> options =
        <(AttendanceStatus?, String)>[
      (AttendanceStatus.present, s.present),
      (AttendanceStatus.halfDay, s.halfDay),
      (AttendanceStatus.absent, s.absent),
      (AttendanceStatus.leave, s.paidLeave),
      (null, s.clearDay),
    ];

    final int? picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 12),
            Text(
              '${s.dayOfMonth(day)}  ·  ${s.monthName(month.month)}',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < options.length; i++)
              ListTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _colorFor(options[i].$1),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppTheme.divider),
                  ),
                ),
                title: Text(options[i].$2),
                onTap: () => Navigator.of(sheetContext).pop(i),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (picked == null) return;
    final AttendanceStatus? status = options[picked].$1;
    if (status == null) {
      await ledger.clearAttendance(staffId: staffId, date: date);
    } else {
      await ledger.markAttendance(
        staffId: staffId,
        date: date,
        status: status,
      );
    }
  }

  /// Fills the month up to today — never into the future, since nobody can
  /// say yet whether they turned up tomorrow.
  Future<void> _markAllPresent(BuildContext context, S s) async {
    final ledger = AppScope.ledgerRead(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final DateTime now = DateTime.now();
    final bool isCurrentMonth =
        now.year == month.year && now.month == month.month;
    final int lastDay =
        isCurrentMonth ? now.day : daysInMonth(month);

    await ledger.markAttendanceForDays(
      staffId: staffId,
      status: AttendanceStatus.present,
      days: <DateTime>[
        for (int day = 1; day <= lastDay; day++)
          DateTime(month.year, month.month, day),
      ],
    );
    messenger.showSnackBar(SnackBar(content: Text(s.allPresentDone)));
  }
}

Color _colorFor(AttendanceStatus? status) => switch (status) {
      AttendanceStatus.present => AppTheme.earn,
      AttendanceStatus.absent => AppTheme.spend,
      AttendanceStatus.halfDay => const Color(0xFFB26A00),
      AttendanceStatus.leave => const Color(0xFF1565C0),
      null => AppTheme.card,
    };

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.status,
    required this.onTap,
    required this.onLongPress,
  });

  final int day;
  final AttendanceStatus? status;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final Color color = _colorFor(status);
    final bool filled = status != null;

    return SizedBox(
      width: 42,
      height: 42,
      child: Material(
        color: filled ? color : AppTheme.card,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: filled ? color : AppTheme.divider,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : AppTheme.inkSoft,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceLegend extends StatelessWidget {
  const _AttendanceLegend();

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final List<(AttendanceStatus, String)> items =
        <(AttendanceStatus, String)>[
      (AttendanceStatus.present, s.present),
      (AttendanceStatus.absent, s.absent),
      (AttendanceStatus.halfDay, s.halfDay),
      (AttendanceStatus.leave, s.paidLeave),
    ];

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: <Widget>[
        for (final (AttendanceStatus status, String label) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _colorFor(status),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 5),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}

/// The month's pay, with the working shown.
class _SalaryCard extends StatelessWidget {
  const _SalaryCard({
    required this.member,
    required this.calculation,
    required this.month,
  });

  final StaffWithAccounts member;
  final SalaryCalculation calculation;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.salaryFor, style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            _line(context, s.monthlySalary, calculation.monthlySalary),
            if (calculation.deduction.isPositive)
              _line(context, s.deduction, -calculation.deduction,
                  color: AppTheme.spend),
            _line(context, s.earnedThisMonthLabel, calculation.earned,
                bold: true),
            if (calculation.advanceSettled.isPositive)
              _line(context, s.peshgi, -calculation.advanceSettled,
                  color: AppTheme.spend),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(s.netPayable, style: theme.textTheme.titleMedium),
                MoneyText(
                  calculation.earned - calculation.advanceSettled,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: AppTheme.earn),
                ),
              ],
            ),
            if (calculation.carriesForward) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                '${s.stillOwed}: ${calculation.carriedForward.format()}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppTheme.spend),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: () => _pay(context, s),
                    child: Text(s.paySalary),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  tooltip: s.sendReceipt,
                  icon: const Icon(Icons.ios_share),
                  onPressed: () => _sendReceipt(context, s),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    Money amount, {
    bool bold = false,
    Color? color,
  }) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = bold
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium?.copyWith(color: color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(label,
                style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          MoneyText(amount, style: style),
        ],
      ),
    );
  }

  Future<void> _pay(BuildContext context, S s) async {
    final ledger = AppScope.ledgerRead(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final _AmountAndSource? result =
        await showModalBottomSheet<_AmountAndSource>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => _AmountSheet(
        title: s.paySalary,
        confirmLabel: s.confirm,
        // The amount is already worked out; this sheet only needs to ask
        // which pocket it comes from.
        fixedAmount: calculation.earned - calculation.advanceSettled,
      ),
    );

    if (result == null) return;
    try {
      await ledger.paySalary(
        member: member,
        calculation: calculation,
        paidFromAccountId: result.sourceId,
      );
      messenger.showSnackBar(SnackBar(content: Text(s.salaryPaid)));
    } on LedgerValidationError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _sendReceipt(BuildContext context, S s) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String monthLabel = '${s.monthName(month.month)} ${month.year}';

    final File file = await ReceiptService.buildSalaryReceipt(
      member: member,
      calculation: calculation,
      monthLabel: monthLabel,
      paidOn: DateTime.now(),
    );
    await ReceiptService.share(
      file,
      message: '${member.name} — $monthLabel',
    );
    messenger.showSnackBar(SnackBar(content: Text(s.receiptSent)));
  }
}

class _AmountAndSource {
  const _AmountAndSource({required this.amount, required this.sourceId});

  final Money amount;
  final String sourceId;
}

/// Asks for an amount and which account it comes from.
class _AmountSheet extends StatefulWidget {
  const _AmountSheet({
    required this.title,
    required this.confirmLabel,
    this.fixedAmount,
  });

  final String title;
  final String confirmLabel;

  /// When set, the amount is shown but not editable — used where the figure
  /// has already been calculated and typing it again would only invite a typo.
  final Money? fixedAmount;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  final TextEditingController _amount = TextEditingController();
  String? _sourceId;

  @override
  void dispose() {
    _amount.dispose();
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
          const SizedBox(height: 16),
          if (widget.fixedAmount != null)
            MoneyText(
              widget.fixedAmount!,
              style: theme.textTheme.displayLarge,
            )
          else
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: 'Rs ',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 18),
          Text(s.paidFrom, style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          StreamBuilder<List<AccountBalance>>(
            stream: AppScope.ledgerOf(context)
                .watchAccountBalances(type: AccountType.asset),
            builder: (
              BuildContext context,
              AsyncSnapshot<List<AccountBalance>> snapshot,
            ) {
              final List<AccountBalance> accounts =
                  snapshot.data ?? const <AccountBalance>[];
              if (accounts.isEmpty) return const SizedBox.shrink();
              _sourceId ??= accounts.first.id;

              return Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final AccountBalance account in accounts)
                    ChoiceChip(
                      avatar: Icon(
                        iconForKey(account.account.iconKey),
                        size: 18,
                        color: colorForIcon(account.account.iconKey),
                      ),
                      label: Text(s.accountName(account.account)),
                      selected: _sourceId == account.id,
                      onSelected: (_) =>
                          setState(() => _sourceId = account.id),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final Money amount = widget.fixedAmount ??
                    (Money.tryParse(_amount.text) ?? Money.zero);
                if (!amount.isPositive || _sourceId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.enterAmount)),
                  );
                  return;
                }
                Navigator.of(context).pop(
                  _AmountAndSource(amount: amount, sourceId: _sourceId!),
                );
              },
              child: Text(widget.confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}
