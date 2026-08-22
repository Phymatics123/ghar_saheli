import 'package:flutter/material.dart';

import '../../domain/recurring.dart';
import '../app_scope.dart';
import '../category_icons.dart';
import '../strings.dart';
import '../theme.dart';
import '../widgets/money_text.dart';
import 'template_editor_screen.dart';

/// The list of monthly bills the household has set up.
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.monthlyBills)),
      body: StreamBuilder<List<DueTemplate>>(
        stream: AppScope.ledgerOf(context).watchTemplates(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<DueTemplate>> snapshot,
        ) {
          final List<DueTemplate> templates =
              snapshot.data ?? const <DueTemplate>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: <Widget>[
              Text(s.monthlyBillsHelp, style: theme.textTheme.bodySmall),
              const SizedBox(height: 18),
              if (templates.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: <Widget>[
                      const Icon(Icons.event_repeat,
                          size: 52, color: AppTheme.inkSoft),
                      const SizedBox(height: 12),
                      Text(s.noMonthlyYet,
                          style: theme.textTheme.titleMedium),
                    ],
                  ),
                )
              else
                for (final DueTemplate template in templates)
                  _TemplateRow(template: template),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(s.addMonthly),
      ),
    );
  }

  static Future<void> _openEditor(
    BuildContext context, {
    DueTemplate? existing,
  }) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TemplateEditorScreen(existing: existing),
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({required this.template});

  final DueTemplate template;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);
    final Color accent = colorForIcon(template.category.iconKey);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 21,
          backgroundColor: accent.withValues(alpha: 0.14),
          child: Icon(iconForKey(template.category.iconKey),
              color: accent, size: 21),
        ),
        title: Text(
          template.template.description,
          style: theme.textTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          s.dayOfMonth(template.template.dayOfMonth),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (template.isVariableAmount)
              Text('—', style: theme.textTheme.bodyMedium)
            else
              MoneyText(template.amount, style: theme.textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppTheme.inkSoft,
              tooltip: s.deleteMonthly,
              onPressed: () => _confirmDelete(context, s),
            ),
          ],
        ),
        onTap: () =>
            TemplatesScreen._openEditor(context, existing: template),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, S s) async {
    final ledger = AppScope.ledgerRead(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(template.template.description),
        content: Text(s.deleteMonthly),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(s.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.spend),
            child: Text(s.deleteMonthly),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ledger.removeTemplate(template.template.id);
    }
  }
}
