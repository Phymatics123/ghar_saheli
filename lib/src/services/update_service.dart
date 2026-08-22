import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/app_update.dart';

/// Where the app looks for news of a newer build.
///
/// A static file on ordinary hosting — GitHub Releases, Firebase Hosting, a
/// folder on a web server. There is no backend to write, and publishing an
/// update is editing one small file.
///
/// **Replace this before shipping.** Left pointing nowhere on purpose, so a
/// forgotten placeholder fails loudly at the first check rather than silently
/// never finding an update.
const String kUpdateManifestUrl =
    'https://example.invalid/ghar-saheli/latest.json';

/// The page a new user is sent to when someone shares the app with them.
///
/// A page rather than the APK itself, on purpose. Tapping a raw `.apk` link
/// drops someone straight into an install prompt with no idea what they are
/// installing; a page can explain what the app is and warn them about the
/// "unknown apps" step before they hit it. Word of mouth through family is
/// realistically how this spreads, so that first impression is the funnel.
///
/// **Replace this before sharing anything.**
const String kAppDownloadPageUrl = 'https://example.invalid/ghar-saheli';

/// Checks for, downloads and installs a new build of the app.
///
/// This is what replaces the Play Store. Three things make it safe enough to
/// live in a finance app:
///
///  1. **HTTPS only.** Enforced when the manifest is parsed, so nobody on the
///     same WiFi can swap the file in transit.
///  2. **A checksum, verified before install.** A download cut short by a
///     dropped connection — which is the common case, not the exotic one — is
///     caught rather than handed to the installer.
///  3. **Android's own signature check.** An APK signed with a different key
///     cannot replace an installed app, whatever this code does. That is the
///     backstop, and it is the strongest guarantee in the chain.
class UpdateService {
  UpdateService({this.manifestUrl = kUpdateManifestUrl});

  final String manifestUrl;

  static const MethodChannel _channel =
      MethodChannel('ghar_saheli/updates');

  // ---- Version ----

  Future<InstalledVersion> installedVersion() async {
    final Map<Object?, Object?>? result =
        await _channel.invokeMethod<Map<Object?, Object?>>('installedVersion');
    if (result == null) {
      throw const UpdateError('Could not read the installed version.');
    }
    return InstalledVersion(
      versionCode: (result['versionCode'] as int?) ?? 0,
      versionName: (result['versionName'] as String?) ?? '',
    );
  }

  // ---- Check ----

  /// Fetches the manifest and compares it with what is installed.
  Future<UpdateCheck> check() async {
    final InstalledVersion installed = await installedVersion();
    final UpdateManifest manifest = await _fetchManifest();
    return UpdateCheck.compare(installed: installed, manifest: manifest);
  }

  Future<UpdateManifest> _fetchManifest() async {
    final Uri? uri = Uri.tryParse(manifestUrl);
    if (uri == null || uri.scheme != 'https') {
      throw const UpdateError('The update address is not set up correctly.');
    }

    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close();

      if (response.statusCode != 200) {
        throw UpdateError(
          'Could not reach the update server (${response.statusCode}).',
        );
      }

      final String body = await response.transform(utf8.decoder).join();
      final Object? decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const UpdateError('The update file could not be read.');
      }
      return UpdateManifest.fromJson(decoded.cast<String, Object?>());
    } on SocketException {
      throw const UpdateError('No internet connection.');
    } on FormatException {
      throw const UpdateError('The update file could not be read.');
    } finally {
      client.close();
    }
  }

  // ---- Download ----

  /// Downloads the APK, checking its digest as the bytes arrive.
  ///
  /// [onProgress] receives a value from 0 to 1, or null while the total size
  /// is unknown — some servers do not send a content length, and a progress
  /// bar that pretends to know is worse than one that admits it does not.
  Future<File> download(
    UpdateManifest manifest, {
    void Function(double? progress)? onProgress,
  }) async {
    final Directory cache = await getTemporaryDirectory();
    final Directory folder = Directory(p.join(cache.path, 'updates'));
    if (!folder.existsSync()) {
      await folder.create(recursive: true);
    }

    // Named for the version, so a half-finished download from a previous
    // attempt is overwritten rather than mistaken for this one.
    final File file =
        File(p.join(folder.path, 'ghar-saheli-${manifest.versionCode}.apk'));
    if (file.existsSync()) await file.delete();

    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    IOSink? sink;

    try {
      final HttpClientRequest request =
          await client.getUrl(Uri.parse(manifest.apkUrl));
      final HttpClientResponse response = await request.close();

      if (response.statusCode != 200) {
        throw UpdateError('Download failed (${response.statusCode}).');
      }

      final int expectedBytes = response.contentLength;
      int received = 0;
      final _DigestCollector digestSink = _DigestCollector();
      final ByteConversionSink hasher =
          sha256.startChunkedConversion(digestSink);

      sink = file.openWrite();
      await for (final List<int> chunk in response) {
        sink.add(chunk);
        hasher.add(chunk);
        received += chunk.length;
        if (onProgress != null) {
          onProgress(expectedBytes > 0 ? received / expectedBytes : null);
        }
      }
      hasher.close();
      await sink.flush();
      await sink.close();
      sink = null;

      final String actual = digestSink.digest.toString();

      if (actual.toLowerCase() != manifest.sha256.toLowerCase()) {
        await file.delete();
        throw const UpdateError(
          'The download did not arrive intact. Please try again.',
        );
      }

      return file;
    } on SocketException {
      throw const UpdateError('The download was interrupted.');
    } finally {
      await sink?.close();
      client.close();
    }
  }

  // ---- Install ----

  /// Whether Android will let this app hand an APK to the installer.
  Future<bool> canInstall() async {
    return await _channel.invokeMethod<bool>('canInstallPackages') ?? false;
  }

  /// Opens the system page where the user grants that permission.
  Future<void> openInstallPermissionSettings() {
    return _channel.invokeMethod<void>('openInstallPermissionSettings');
  }

  /// Hands the verified APK to Android's installer.
  ///
  /// What happens next is out of the app's hands, and deliberately so: the
  /// user sees Android's own install screen, with Android's own warnings, and
  /// decides. Nothing here can install anything behind their back.
  Future<void> install(File apk) async {
    await _channel.invokeMethod<bool>('installApk', <String, Object?>{
      'path': apk.path,
    });
  }

  /// Removes any downloaded APKs left behind.
  Future<void> clearDownloads() async {
    final Directory cache = await getTemporaryDirectory();
    final Directory folder = Directory(p.join(cache.path, 'updates'));
    if (folder.existsSync()) {
      await folder.delete(recursive: true);
    }
  }
}

/// Catches the single [Digest] that `sha256`'s chunked conversion emits.
///
/// Hashing as the bytes arrive costs nothing extra. Hashing afterwards would
/// mean reading the whole APK back off a slow phone's storage a second time,
/// which on the devices this app targets is a visible pause.
class _DigestCollector implements Sink<Digest> {
  Digest? _digest;

  Digest get digest {
    final Digest? value = _digest;
    if (value == null) {
      throw const UpdateError('The download could not be checked.');
    }
    return value;
  }

  @override
  void add(Digest data) => _digest = data;

  @override
  void close() {}
}
