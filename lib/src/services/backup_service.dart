import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';

import '../core/hlc.dart';
import '../domain/ledger_event.dart';
import '../domain/ledger_repository.dart';

/// Arguments for the key derivation, which runs on a background isolate.
class _KeyRequest {
  const _KeyRequest(this.passphrase, this.salt);

  final String passphrase;
  final Uint8List salt;
}

/// Top-level so it can be handed to [compute].
///
/// A hundred thousand HMAC rounds is a second or more of solid arithmetic on
/// the phones this app targets. Run on the UI thread it freezes the screen
/// mid-tap, which reads as the app having crashed.
Uint8List _deriveKeyIsolate(_KeyRequest request) {
  final Hmac hmac = Hmac(sha256, utf8.encode(request.passphrase));
  List<int> block =
      hmac.convert(<int>[...request.salt, 0, 0, 0, 1]).bytes;
  final List<int> result = List<int>.of(block);

  for (int i = 1; i < BackupService.iterations; i++) {
    block = hmac.convert(block).bytes;
    for (int j = 0; j < result.length; j++) {
      result[j] ^= block[j];
    }
  }
  return Uint8List.fromList(result);
}

/// Something went wrong reading a backup. Carries a message meant for the
/// user, because every one of these is a situation they can act on — a wrong
/// passphrase, the wrong file, a truncated download.
class BackupError implements Exception {
  const BackupError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Encrypted backup and restore.
///
/// What gets backed up is **the event log, not the database file**. Every table
/// in the app is a projection of that log, so the log is both smaller and more
/// durable: it survives schema changes, it can be read back by a future version
/// that stores things differently, and it can be merged rather than only
/// replaced.
///
/// That last property is what makes this double as family sync. Applying an
/// event is idempotent by event id, so importing a relative's backup adds what
/// their phone knows and silently skips what yours already has. Two phones
/// exchanging files over WhatsApp converge on the same ledger, with no server,
/// no account and no hosting — which was the constraint this whole app was
/// built under.
///
/// It is manual, and that is the honest limit: nothing syncs until someone
/// sends a file. Automatic sync needs something in the middle that both phones
/// can reach, and that is a different decision than "no cloud".
class BackupService {
  BackupService(this._ledger);

  final LedgerRepository _ledger;

  static final Random _random = Random.secure();

  /// Identifies the format on sight, before anything is decrypted, so a photo
  /// picked by mistake fails with "this is not a backup" rather than "wrong
  /// password".
  static const String _magic = 'GHARSAHELI';
  static const int _formatVersion = 1;

  static const int _saltLength = 16;

  /// 96 bits — the size GCM is specified for.
  static const int _nonceLength = 12;

  /// A real passphrase, unlike the four-digit screen PIN, is worth stretching
  /// properly. This costs a noticeable moment on a budget phone, which is the
  /// intended trade: it happens twice in the life of a backup.
  static const int iterations = 100000;

  // ---- Export ----

  /// Builds the encrypted backup and hands back its bytes.
  ///
  /// Bytes rather than a file, because the file is written by the system save
  /// dialog wherever the user chooses. Writing it here first would leave a
  /// copy of the whole ledger sitting in the cache as well.
  Future<Uint8List> exportBytes({required String passphrase}) async {
    if (passphrase.length < 4) {
      throw const BackupError('Choose a longer password.');
    }

    final List<LedgerEvent> events = await _ledger.exportEvents();
    final String json = jsonEncode(<String, Object?>{
      'app': 'ghar_saheli',
      'formatVersion': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'deviceId': _ledger.deviceId,
      'eventCount': events.length,
      'events': events.map((LedgerEvent e) => e.toWireJson()).toList(),
    });

    final Uint8List salt = _randomBytes(_saltLength);
    final Uint8List nonce = _randomBytes(_nonceLength);
    final enc.Key key = enc.Key(
      await compute(_deriveKeyIsolate, _KeyRequest(passphrase, salt)),
    );

    final enc.Encrypter encrypter =
        enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final enc.Encrypted encrypted = encrypter.encryptBytes(
      utf8.encode(json),
      iv: enc.IV(nonce),
    );

    // header | salt | nonce | ciphertext+tag
    final BytesBuilder out = BytesBuilder()
      ..add(utf8.encode(_magic))
      ..addByte(_formatVersion)
      ..add(salt)
      ..add(nonce)
      ..add(encrypted.bytes);

    return out.toBytes();
  }

  /// A sensible default name for the save dialog.
  static String suggestedFileName() {
    final DateTime now = DateTime.now();
    final String stamp = '${now.year}'
        '-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}';
    return 'ghar-saheli-backup-$stamp.ghar';
  }

  // ---- Import ----

  /// Reads a backup and folds its events into this device's ledger.
  ///
  /// Returns how many events were new. Anything already present is skipped by
  /// the repository, so importing the same file twice is safe and importing a
  /// family member's file merges rather than overwrites.
  Future<BackupImportResult> import({
    required File file,
    required String passphrase,
  }) async {
    final Uint8List bytes = await file.readAsBytes();
    final Map<String, Object?> payload = await _decrypt(bytes, passphrase);

    final Object? rawEvents = payload['events'];
    if (rawEvents is! List) {
      throw const BackupError('This backup has no entries in it.');
    }

    final List<LedgerEvent> events = <LedgerEvent>[];
    for (final Object? raw in rawEvents) {
      if (raw is! Map) continue;
      try {
        events.add(LedgerEvent.fromWireJson(raw.cast<String, Object?>()));
      } on Object {
        // One unreadable event should not cost the user the other thousand.
        continue;
      }
    }

    if (events.isEmpty) {
      throw const BackupError('This backup has no entries in it.');
    }

    final int before = await _ledger.exportEvents().then(
          (List<LedgerEvent> existing) => existing.length,
        );
    await _ledger.ingestRemoteEvents(events);
    final int after = await _ledger.exportEvents().then(
          (List<LedgerEvent> existing) => existing.length,
        );

    return BackupImportResult(
      totalInFile: events.length,
      added: after - before,
      exportedAt: payload['exportedAt'] as String?,
    );
  }

  Future<Map<String, Object?>> _decrypt(Uint8List bytes, String passphrase) async {
    final Uint8List magic = Uint8List.fromList(utf8.encode(_magic));
    final int headerLength = magic.length + 1;
    final int minimumLength = headerLength + _saltLength + _nonceLength;

    if (bytes.length < minimumLength) {
      throw const BackupError('This file is not a Ghar Saheli backup.');
    }
    for (int i = 0; i < magic.length; i++) {
      if (bytes[i] != magic[i]) {
        throw const BackupError('This file is not a Ghar Saheli backup.');
      }
    }
    if (bytes[magic.length] != _formatVersion) {
      throw const BackupError(
        'This backup was made by a newer version of the app.',
      );
    }

    int offset = headerLength;
    final Uint8List salt =
        Uint8List.sublistView(bytes, offset, offset + _saltLength);
    offset += _saltLength;
    final Uint8List nonce =
        Uint8List.sublistView(bytes, offset, offset + _nonceLength);
    offset += _nonceLength;
    final Uint8List cipherText = Uint8List.sublistView(bytes, offset);

    final enc.Key key = enc.Key(
      await compute(_deriveKeyIsolate, _KeyRequest(passphrase, salt)),
    );
    final enc.Encrypter encrypter =
        enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final List<int> plain;
    try {
      plain = encrypter.decryptBytes(
        enc.Encrypted(cipherText),
        iv: enc.IV(nonce),
      );
    } on Object {
      // GCM authenticates as well as encrypts, so this one branch covers both
      // a wrong password and a file that was damaged in transit. The app
      // cannot tell them apart, and should not pretend to.
      throw const BackupError(
        'Wrong password, or this file is damaged.',
      );
    }

    try {
      return jsonDecode(utf8.decode(plain)) as Map<String, Object?>;
    } on Object {
      throw const BackupError('This backup could not be read.');
    }
  }

  // ---- Crypto helpers ----

  static Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }

  /// The newest event this device holds, for showing when it last changed.
  Future<Hlc?> latestEvent() async {
    final List<LedgerEvent> events = await _ledger.exportEvents();
    return events.isEmpty ? null : events.last.hlc;
  }
}

class BackupImportResult {
  const BackupImportResult({
    required this.totalInFile,
    required this.added,
    this.exportedAt,
  });

  final int totalInFile;

  /// New to this device. Zero means the file held nothing this phone did not
  /// already know — which is a successful merge, not a failure.
  final int added;

  final String? exportedAt;

  int get alreadyHad => totalInFile - added;
}
