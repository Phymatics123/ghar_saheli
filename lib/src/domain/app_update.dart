/// What the server publishes to say a new build exists.
///
/// Kept deliberately small and boring. This file is written by hand or by a
/// release script and sits on static hosting; anything clever in its shape
/// becomes something that can be got wrong at the exact moment an update needs
/// to go out.
class UpdateManifest {
  const UpdateManifest({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    required this.sha256,
    this.sizeBytes,
    this.mandatory = false,
    this.notesUr,
    this.notesRoman,
    this.notesEn,
  });

  /// The integer Android actually compares. `versionName` is for people.
  final int versionCode;
  final String versionName;

  final String apkUrl;

  /// Lowercase hex digest of the APK. Checked after download, before install.
  final String sha256;

  final int? sizeBytes;

  /// Blocks use of the old build. Reserved for the case where an old version
  /// would corrupt data — not for nagging.
  final bool mandatory;

  final String? notesUr;
  final String? notesRoman;
  final String? notesEn;

  static UpdateManifest fromJson(Map<String, Object?> json) {
    final Object? versionCode = json['versionCode'];
    final Object? apkUrl = json['apkUrl'];
    final Object? digest = json['sha256'];

    if (versionCode is! int || versionCode <= 0) {
      throw const UpdateError('The update file is missing a version number.');
    }
    if (apkUrl is! String || apkUrl.isEmpty) {
      throw const UpdateError('The update file is missing a download link.');
    }
    if (digest is! String || digest.length != 64) {
      throw const UpdateError('The update file is missing its checksum.');
    }

    // Plain HTTP would let anyone on the same network hand the phone a
    // different file *and* a matching checksum, since both travel together.
    // Android still refuses to install an APK signed with another key, but
    // there is no reason to rely on that as the only line of defence.
    final Uri? parsed = Uri.tryParse(apkUrl);
    if (parsed == null || parsed.scheme != 'https') {
      throw const UpdateError('Updates can only be downloaded over HTTPS.');
    }

    final Map<String, Object?> notes =
        (json['notes'] as Map<Object?, Object?>?)?.cast<String, Object?>() ??
            const <String, Object?>{};

    return UpdateManifest(
      versionCode: versionCode,
      versionName: (json['versionName'] as String?) ?? '$versionCode',
      apkUrl: apkUrl,
      sha256: digest.toLowerCase(),
      sizeBytes: json['sizeBytes'] as int?,
      mandatory: (json['mandatory'] as bool?) ?? false,
      notesUr: notes['ur'] as String?,
      notesRoman: notes['roman'] as String?,
      notesEn: notes['en'] as String?,
    );
  }

  /// Human-readable size, for telling someone on mobile data what this costs.
  String get sizeLabel {
    final int? bytes = sizeBytes;
    if (bytes == null || bytes <= 0) return '';
    final double mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}

/// The installed build, read from the Android package manager.
class InstalledVersion {
  const InstalledVersion({
    required this.versionCode,
    required this.versionName,
  });

  final int versionCode;
  final String versionName;
}

enum UpdateStatus {
  upToDate,
  available,

  /// The server is behind the phone. Happens when a manifest is rolled back,
  /// and must never trigger an install — Android would refuse the downgrade
  /// anyway, but offering it would be a confusing dead end.
  serverIsOlder,
}

class UpdateCheck {
  const UpdateCheck({
    required this.status,
    required this.installed,
    this.manifest,
  });

  final UpdateStatus status;
  final InstalledVersion installed;
  final UpdateManifest? manifest;

  bool get hasUpdate => status == UpdateStatus.available;

  bool get isMandatory =>
      status == UpdateStatus.available && (manifest?.mandatory ?? false);

  /// Compares by version code, never by name.
  ///
  /// Version names are marketing strings — "1.10" sorts before "1.9" as text
  /// and after it as a version, and nothing forces them to be ordered at all.
  /// The integer code is the one thing Android itself guarantees increases.
  static UpdateCheck compare({
    required InstalledVersion installed,
    required UpdateManifest manifest,
  }) {
    final UpdateStatus status;
    if (manifest.versionCode > installed.versionCode) {
      status = UpdateStatus.available;
    } else if (manifest.versionCode < installed.versionCode) {
      status = UpdateStatus.serverIsOlder;
    } else {
      status = UpdateStatus.upToDate;
    }

    return UpdateCheck(
      status: status,
      installed: installed,
      manifest: manifest,
    );
  }
}

/// A problem the user can be told about in plain words.
class UpdateError implements Exception {
  const UpdateError(this.message);

  final String message;

  @override
  String toString() => message;
}
