import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/app_update.dart';
import '../../services/update_service.dart';
import '../app_scope.dart';
import '../strings.dart';
import '../theme.dart';

/// Checking for and installing a new build.
///
/// This is what the Play Store would otherwise do, and the screen is honest
/// that it is not the Play Store: it warns before the download that Android
/// will show its own warning, because a user who is surprised by that warning
/// abandons the install, while one who was told to expect it does not.
class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

enum _Phase { checking, upToDate, available, downloading, ready, failed }

class _UpdateScreenState extends State<UpdateScreen> {
  final UpdateService _service = UpdateService();

  _Phase _phase = _Phase.checking;
  UpdateCheck? _check;
  File? _downloaded;
  double? _progress;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runCheck();
  }

  Future<void> _runCheck() async {
    setState(() {
      _phase = _Phase.checking;
      _error = null;
    });
    try {
      final UpdateCheck result = await _service.check();
      if (!mounted) return;
      setState(() {
        _check = result;
        _phase = result.hasUpdate ? _Phase.available : _Phase.upToDate;
      });
    } on UpdateError catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _error = error.message;
      });
    }
  }

  Future<void> _download() async {
    final UpdateManifest? manifest = _check?.manifest;
    if (manifest == null) return;

    setState(() {
      _phase = _Phase.downloading;
      _progress = null;
      _error = null;
    });

    try {
      final File file = await _service.download(
        manifest,
        onProgress: (double? value) {
          if (mounted) setState(() => _progress = value);
        },
      );
      if (!mounted) return;
      setState(() {
        _downloaded = file;
        _phase = _Phase.ready;
      });
    } on UpdateError catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _error = error.message;
      });
    }
  }

  Future<void> _install() async {
    final File? file = _downloaded;
    if (file == null) return;

    // Asking permission only at the moment it is needed, rather than on first
    // launch. A permission prompt makes sense next to the button that needs
    // it; the same prompt at startup looks like the app overreaching.
    if (!await _service.canInstall()) {
      if (!mounted) return;
      final bool? granted = await _showPermissionSheet();
      if (granted != true) return;
      if (!await _service.canInstall()) return;
    }

    try {
      await _service.install(file);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _error = '$error';
      });
    }
  }

  Future<bool?> _showPermissionSheet() {
    final S s = AppScope.stringsOf(context);
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(s.allowInstalls,
                  style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(s.allowInstallsWhy,
                  style: Theme.of(sheetContext).textTheme.bodyMedium),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  await _service.openInstallPermissionSettings();
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop(true);
                  }
                },
                child: Text(s.openSettings),
              ),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: Text(s.notNow),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = AppScope.stringsOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.appUpdate)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: _buildBody(s)),
            _buildAction(s),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(S s) {
    final ThemeData theme = Theme.of(context);
    final UpdateCheck? check = _check;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(_iconFor(_phase), size: 56, color: _colorFor(_phase)),
        const SizedBox(height: 18),
        Text(
          _headlineFor(s),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),

        if (check != null) ...<Widget>[
          Text(
            s.currentVersion(check.installed.versionName),
            style: theme.textTheme.bodySmall,
          ),
          if (check.hasUpdate)
            Text(
              s.newVersion(check.manifest!.versionName),
              style: theme.textTheme.bodyMedium,
            ),
          if (check.hasUpdate && check.manifest!.sizeLabel.isNotEmpty)
            Text(check.manifest!.sizeLabel,
                style: theme.textTheme.bodySmall),
        ],

        if (_phase == _Phase.available) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            _notesFor(check!.manifest!) ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(s.updateOnWifi, style: theme.textTheme.bodySmall),
        ],

        if (_phase == _Phase.downloading) ...<Widget>[
          const SizedBox(height: 20),
          LinearProgressIndicator(value: _progress),
          if (_progress != null) ...<Widget>[
            const SizedBox(height: 6),
            Text('${(_progress! * 100).round()}%',
                style: theme.textTheme.bodySmall),
          ],
        ],

        if (_phase == _Phase.ready) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            s.installWarningNote,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],

        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppTheme.spend),
          ),
        ],
      ],
    );
  }

  Widget _buildAction(S s) {
    return switch (_phase) {
      _Phase.checking => const SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator()),
        ),
      _Phase.upToDate || _Phase.failed => FilledButton.tonal(
          onPressed: _runCheck,
          child: Text(s.checkForUpdates),
        ),
      _Phase.available => FilledButton.icon(
          onPressed: _download,
          icon: const Icon(Icons.download),
          label: Text(s.downloadUpdate),
        ),
      _Phase.downloading => const SizedBox(height: 56),
      _Phase.ready => FilledButton.icon(
          onPressed: _install,
          icon: const Icon(Icons.system_update),
          label: Text(s.installNow),
        ),
    };
  }

  String _headlineFor(S s) => switch (_phase) {
        _Phase.checking => s.checking,
        _Phase.upToDate => s.upToDate,
        _Phase.available => s.updateAvailable,
        _Phase.downloading => s.downloading,
        _Phase.ready => s.installNow,
        _Phase.failed => s.appUpdate,
      };

  IconData _iconFor(_Phase phase) => switch (phase) {
        _Phase.checking || _Phase.downloading => Icons.cloud_download_outlined,
        _Phase.upToDate => Icons.check_circle_outline,
        _Phase.available => Icons.new_releases_outlined,
        _Phase.ready => Icons.system_update,
        _Phase.failed => Icons.error_outline,
      };

  Color _colorFor(_Phase phase) => switch (phase) {
        _Phase.upToDate => AppTheme.earn,
        _Phase.failed => AppTheme.spend,
        _ => AppTheme.primary,
      };

  /// Release notes in whichever language the app is speaking, falling through
  /// rather than showing nothing when a translation was not written.
  String? _notesFor(UpdateManifest manifest) {
    final AppLanguage language = AppScope.settingsOf(context).language;
    return switch (language) {
      AppLanguage.urdu =>
        manifest.notesUr ?? manifest.notesRoman ?? manifest.notesEn,
      AppLanguage.roman =>
        manifest.notesRoman ?? manifest.notesEn ?? manifest.notesUr,
      AppLanguage.english =>
        manifest.notesEn ?? manifest.notesRoman ?? manifest.notesUr,
    };
  }
}
