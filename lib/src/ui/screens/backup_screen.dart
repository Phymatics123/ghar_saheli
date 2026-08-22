import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../services/backup_service.dart';
import '../../services/statement_pdf.dart';
import '../app_scope.dart';
import '../strings.dart';
import '../theme.dart';

/// Making and restoring an encrypted backup.
///
/// Restoring is also how two phones in one household end up with the same
/// ledger. Because every change is an event with an id, and applying an event
/// twice does nothing, importing a relative's backup merges their entries into
/// yours instead of replacing them. No server, no account, no hosting — the
/// file travels however the family already sends files to each other.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.backup)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: <Widget>[
          Text(s.backupHelp, style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.lock_outline, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.makeBackup,
                            style: theme.textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(s.backupSaveHelp, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _export,
                      icon: const Icon(Icons.ios_share),
                      label: Text(s.makeBackup),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.description_outlined,
                          color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.statement,
                            style: theme.textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(s.statementHelp, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: _busy ? null : _saveStatement,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(s.saveStatement),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.restore, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.restoreBackup,
                            style: theme.textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: _busy ? null : _import,
                      icon: const Icon(Icons.folder_open),
                      label: Text(s.chooseFile),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.info_outline, size: 18, color: AppTheme.inkSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(s.backupPasswordHelp,
                    style: theme.textTheme.bodySmall),
              ),
            ],
          ),

          if (_busy) ...<Widget>[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  /// Builds the backup and hands it to Android's save dialog.
  ///
  /// A save dialog, not a share sheet. The point of a backup is to end up
  /// somewhere the user can find it again — their Downloads folder, an SD
  /// card, Drive — and choosing that is the system's job, not a list of chat
  /// apps to send it to.
  Future<void> _export() async {
    final S s = AppScope.stringsOf(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final BackupService service = BackupService(AppScope.ledgerRead(context));

    final String? password = await _askPassword(s, s.makeBackup);
    if (password == null) return;

    setState(() => _busy = true);
    try {
      final Uint8List bytes = await service.exportBytes(passphrase: password);
      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: s.makeBackup,
        fileName: BackupService.suggestedFileName(),
        bytes: bytes,
      );
      if (path == null) return;
      messenger.showSnackBar(SnackBar(content: Text(s.backupReady)));
    } on BackupError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Saves a readable statement of the last month.
  ///
  /// The encrypted backup can only be opened by this app; nobody can look at
  /// it and see what they spent. This is the file for reading — a month of
  /// entries, what went where, and the totals.
  Future<void> _saveStatement() async {
    final S s = AppScope.stringsOf(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ledger = AppScope.ledgerRead(context);

    setState(() => _busy = true);
    try {
      final DateTime now = DateTime.now();
      final DateTime to = DateTime(now.year, now.month, now.day);
      // The same date one month back, so a statement pulled on the 9th of
      // November covers the 9th of October onwards.
      final DateTime from = DateTime(to.year, to.month - 1, to.day);

      final List<EntryWithPostings> entries =
          await ledger.watchEntries(from: from, to: to).first;

      final Uint8List bytes = await StatementService.build(
        entries: entries,
        from: from,
        to: to,
      );

      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: s.saveStatement,
        fileName: StatementService.suggestedFileName(to),
        bytes: bytes,
      );
      if (path == null) return;
      messenger.showSnackBar(SnackBar(content: Text(s.statementSaved)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final S s = AppScope.stringsOf(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final BackupService service =
        BackupService(AppScope.ledgerRead(context));

    // No extension filter. Android's picker treats unknown extensions
    // inconsistently across manufacturers, and a filter that hides the user's
    // own backup is worse than one file-type mistake, which the header check
    // catches anyway.
    final FilePickerResult? picked = await FilePicker.platform.pickFiles();
    final String? path = picked?.files.single.path;
    if (path == null) return;

    if (!mounted) return;
    final String? password = await _askPassword(s, s.restoreBackup);
    if (password == null) return;

    setState(() => _busy = true);
    try {
      final BackupImportResult result = await service.import(
        file: File(path),
        passphrase: password,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            s.restoredCount(result.added, result.alreadyHad),
          ),
        ),
      );
    } on BackupError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askPassword(S s, String title) {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(
            labelText: s.backupPassword,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.notNow),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
            child: Text(s.confirm),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}
