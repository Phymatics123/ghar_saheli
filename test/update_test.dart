import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_saheli/src/domain/app_update.dart';

/// Everything about updates that can be checked without a phone.
///
/// Deliberately thorough, because the parts that *cannot* be tested here — the
/// download, the FileProvider handoff, Android's installer — have the slowest
/// debugging loop in the project. Every bug caught in this file is one that
/// does not have to be found by building an APK, uploading it, and watching an
/// install fail.
void main() {
  Map<String, Object?> validJson({
    int versionCode = 2,
    String versionName = '1.0.1',
    String apkUrl = 'https://example.com/app.apk',
    String? sha256,
    Object? notes,
    bool? mandatory,
    int? sizeBytes,
  }) {
    return <String, Object?>{
      'versionCode': versionCode,
      'versionName': versionName,
      'apkUrl': apkUrl,
      'sha256': sha256 ?? 'a' * 64,
      if (sizeBytes != null) 'sizeBytes': sizeBytes,
      if (mandatory != null) 'mandatory': mandatory,
      if (notes != null) 'notes': notes,
    };
  }

  group('UpdateManifest parsing', () {
    test('reads a well-formed manifest', () {
      final UpdateManifest manifest = UpdateManifest.fromJson(
        validJson(sizeBytes: 8 * 1024 * 1024),
      );
      expect(manifest.versionCode, 2);
      expect(manifest.versionName, '1.0.1');
      expect(manifest.sizeLabel, '8.0 MB');
      expect(manifest.mandatory, isFalse);
    });

    test('rejects plain HTTP', () {
      // Over HTTP an attacker on the same WiFi could swap both the APK and the
      // checksum that is supposed to vouch for it, since they travel together.
      expect(
        () => UpdateManifest.fromJson(
          validJson(apkUrl: 'http://example.com/app.apk'),
        ),
        throwsA(isA<UpdateError>()),
      );
    });

    test('rejects a missing or malformed checksum', () {
      expect(
        () => UpdateManifest.fromJson(validJson(sha256: 'tooshort')),
        throwsA(isA<UpdateError>()),
      );
      final Map<String, Object?> json = validJson()..remove('sha256');
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(isA<UpdateError>()),
      );
    });

    test('rejects a missing or nonsensical version code', () {
      final Map<String, Object?> missing = validJson()..remove('versionCode');
      expect(
        () => UpdateManifest.fromJson(missing),
        throwsA(isA<UpdateError>()),
      );
      expect(
        () => UpdateManifest.fromJson(validJson(versionCode: 0)),
        throwsA(isA<UpdateError>()),
      );
    });

    test('rejects a missing download link', () {
      final Map<String, Object?> json = validJson()..remove('apkUrl');
      expect(
        () => UpdateManifest.fromJson(json),
        throwsA(isA<UpdateError>()),
      );
    });

    test('lowercases the checksum so comparison is not case-sensitive', () {
      final UpdateManifest manifest =
          UpdateManifest.fromJson(validJson(sha256: 'A' * 64));
      expect(manifest.sha256, 'a' * 64);
    });

    test('survives a manifest with no notes and no size', () {
      final UpdateManifest manifest = UpdateManifest.fromJson(validJson());
      expect(manifest.notesUr, isNull);
      expect(manifest.sizeLabel, '');
    });

    test('reads notes in all three languages', () {
      final UpdateManifest manifest = UpdateManifest.fromJson(
        validJson(notes: <String, Object?>{
          'ur': 'نئی چیزیں',
          'roman': 'Nayi cheezein',
          'en': 'New things',
        }),
      );
      expect(manifest.notesUr, 'نئی چیزیں');
      expect(manifest.notesRoman, 'Nayi cheezein');
      expect(manifest.notesEn, 'New things');
    });

    test('falls back to the version code when no name is given', () {
      final Map<String, Object?> json = validJson()..remove('versionName');
      expect(UpdateManifest.fromJson(json).versionName, '2');
    });
  });

  group('UpdateCheck comparison', () {
    UpdateCheck check(int installedCode, int serverCode) {
      return UpdateCheck.compare(
        installed: InstalledVersion(
          versionCode: installedCode,
          versionName: '$installedCode',
        ),
        manifest: UpdateManifest.fromJson(validJson(versionCode: serverCode)),
      );
    }

    test('a higher server version is an update', () {
      expect(check(1, 2).status, UpdateStatus.available);
      expect(check(1, 2).hasUpdate, isTrue);
    });

    test('the same version is up to date', () {
      expect(check(5, 5).status, UpdateStatus.upToDate);
      expect(check(5, 5).hasUpdate, isFalse);
    });

    test('a lower server version never offers a downgrade', () {
      // Happens when a manifest is rolled back. Android would refuse the
      // install anyway; offering it would be a dead end the user cannot get
      // out of.
      final UpdateCheck result = check(9, 3);
      expect(result.status, UpdateStatus.serverIsOlder);
      expect(result.hasUpdate, isFalse);
    });

    test('a large version jump still counts as one update', () {
      expect(check(1, 47).hasUpdate, isTrue);
    });

    test('mandatory only applies when there is actually an update', () {
      final UpdateCheck sameVersion = UpdateCheck.compare(
        installed: const InstalledVersion(versionCode: 4, versionName: '4'),
        manifest: UpdateManifest.fromJson(
          validJson(versionCode: 4, mandatory: true),
        ),
      );
      expect(sameVersion.isMandatory, isFalse);

      final UpdateCheck newer = UpdateCheck.compare(
        installed: const InstalledVersion(versionCode: 4, versionName: '4'),
        manifest: UpdateManifest.fromJson(
          validJson(versionCode: 5, mandatory: true),
        ),
      );
      expect(newer.isMandatory, isTrue);
    });

    test('ordering follows the code, not the version name', () {
      // "1.10" sorts before "1.9" as text and after it as a version. This is
      // exactly why the comparison never touches the name.
      final UpdateCheck result = UpdateCheck.compare(
        installed: const InstalledVersion(versionCode: 9, versionName: '1.9'),
        manifest: UpdateManifest.fromJson(
          validJson(versionCode: 10, versionName: '1.10'),
        ),
      );
      expect(result.hasUpdate, isTrue);
    });
  });
}
