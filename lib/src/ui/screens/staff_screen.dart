import 'package:flutter/material.dart';

import '../../domain/staff.dart';
import '../app_scope.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/money_text.dart';
import 'staff_detail_screen.dart';
import 'staff_editor_screen.dart';

/// Everyone who works in the house.
class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.staff)),
      body: StreamBuilder<List<StaffWithAccounts>>(
        stream: AppScope.ledgerOf(context).watchStaff(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<StaffWithAccounts>> snapshot,
        ) {
          final List<StaffWithAccounts> staff =
              snapshot.data ?? const <StaffWithAccounts>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: <Widget>[
              Text(s.staffHelp, style: theme.textTheme.bodySmall),
              const SizedBox(height: 18),
              if (staff.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: <Widget>[
                      const Icon(Icons.people_outline,
                          size: 52, color: AppTheme.inkSoft),
                      const SizedBox(height: 12),
                      Text(s.noStaffYet, style: theme.textTheme.titleMedium),
                    ],
                  ),
                )
              else
                for (final StaffWithAccounts member in staff)
                  _StaffRow(member: member),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt),
        label: Text(s.addStaff),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const StaffEditorScreen()),
        ),
      ),
    );
  }
}

class _StaffRow extends StatelessWidget {
  const _StaffRow({required this.member});

  final StaffWithAccounts member;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);
    final bool owesAdvance = member.outstandingAdvance.isPositive;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 23,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.13),
          child: Text(
            member.name.characters.first.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primary,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: theme.textTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: <Widget>[
            MoneyText(member.monthlySalary, style: theme.textTheme.bodySmall),
            if (owesAdvance) ...<Widget>[
              Text(' · ', style: theme.textTheme.bodySmall),
              Flexible(
                child: Text(
                  '${s.peshgi} ${member.outstandingAdvance.format()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.spend,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => StaffDetailScreen(staffId: member.id),
          ),
        ),
      ),
    );
  }
}
