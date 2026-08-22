import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';

/// Exercises the exact crypto construction `BackupService` uses.
///
/// The service itself needs a database and a repository, so these tests rebuild
/// its scheme rather than calling it — which is the part worth being certain
/// about anyway. A backup that cannot be decrypted is a user's entire ledger
/// gone, and a backup that decrypts wrong data without complaining is worse.
///
/// If this construction is ever changed in `backup_service.dart`, these tests
/// must be changed to match, and existing backups will stop opening.
void main() {
  const int iterations = 100000;

  Uint8List deriveKey(String passphrase, Uint8List salt) {
    final Hmac hmac = Hmac(sha256, utf8.encode(passphrase));
    List<int> block = hmac.convert(<int>[...salt, 0, 0, 0, 1]).bytes;
    final List<int> result = List<int>.of(block);
    for (int i = 1; i < iterations; i++) {
      block = hmac.convert(block).bytes;
      for (int j = 0; j < result.length; j++) {
        result[j] ^= block[j];
      }
    }
    return Uint8List.fromList(result);
  }

  final Uint8List salt = Uint8List.fromList(List<int>.generate(16, (int i) => i));
  final Uint8List nonce =
      Uint8List.fromList(List<int>.generate(12, (int i) => i * 3));

  enc.Encrypter encrypterFor(String passphrase, Uint8List withSalt) {
    return enc.Encrypter(
      enc.AES(enc.Key(deriveKey(passphrase, withSalt)), mode: enc.AESMode.gcm),
    );
  }

  group('backup encryption', () {
    test('a round trip returns exactly what went in', () {
      const String secret = 'raashan 2500, kiraya 45000';
      final enc.Encrypter encrypter = encrypterFor('hamara ghar', salt);

      final enc.Encrypted sealed = encrypter.encryptBytes(
        utf8.encode(secret),
        iv: enc.IV(nonce),
      );
      final List<int> opened = encrypter.decryptBytes(
        sealed,
        iv: enc.IV(nonce),
      );

      expect(utf8.decode(opened), secret);
    });

    test('the ciphertext does not contain the plaintext', () {
      final enc.Encrypter encrypter = encrypterFor('hamara ghar', salt);
      final enc.Encrypted sealed = encrypter.encryptBytes(
        utf8.encode('kiraya 45000'),
        iv: enc.IV(nonce),
      );
      expect(utf8.decode(sealed.bytes, allowMalformed: true),
          isNot(contains('45000')));
    });

    test('a wrong password fails instead of returning rubbish', () {
      final enc.Encrypted sealed = encrypterFor('correct horse', salt)
          .encryptBytes(utf8.encode('ledger'), iv: enc.IV(nonce));

      expect(
        () => encrypterFor('wrong horse', salt)
            .decryptBytes(sealed, iv: enc.IV(nonce)),
        throwsA(anything),
      );
    });

    test('a tampered file is rejected rather than silently restored', () {
      // The reason for GCM over plain AES. Flipping one byte of a CBC file
      // would decrypt to corrupted-but-accepted data; here it fails outright.
      final enc.Encrypter encrypter = encrypterFor('hamara ghar', salt);
      final enc.Encrypted sealed = encrypter.encryptBytes(
        utf8.encode('salary 15000'),
        iv: enc.IV(nonce),
      );

      final Uint8List damaged = Uint8List.fromList(sealed.bytes);
      damaged[4] = damaged[4] ^ 0xFF;

      expect(
        () => encrypter.decryptBytes(enc.Encrypted(damaged), iv: enc.IV(nonce)),
        throwsA(anything),
      );
    });

    test('a truncated file is rejected', () {
      final enc.Encrypter encrypter = encrypterFor('hamara ghar', salt);
      final enc.Encrypted sealed = encrypter.encryptBytes(
        utf8.encode('salary 15000'),
        iv: enc.IV(nonce),
      );
      final Uint8List cut =
          Uint8List.sublistView(Uint8List.fromList(sealed.bytes), 0, 6);

      expect(
        () => encrypter.decryptBytes(enc.Encrypted(cut), iv: enc.IV(nonce)),
        throwsA(anything),
      );
    });

    test('the same password with a different salt gives a different key', () {
      // Why the salt is stored per backup: without it, two households using
      // the same password would share a key.
      final Uint8List otherSalt =
          Uint8List.fromList(List<int>.generate(16, (int i) => 200 - i));
      expect(
        deriveKey('hamara ghar', salt),
        isNot(equals(deriveKey('hamara ghar', otherSalt))),
      );
    });

    test('the derived key is 256 bits', () {
      expect(deriveKey('hamara ghar', salt).length, 32);
    });

    test('key derivation is deterministic', () {
      // Restoring has to reach the same key the export used, or the backup is
      // unopenable.
      expect(
        deriveKey('hamara ghar', salt),
        equals(deriveKey('hamara ghar', salt)),
      );
    });

    test('a realistic ledger payload survives the round trip', () {
      final String json = jsonEncode(<String, Object?>{
        'app': 'ghar_saheli',
        'formatVersion': 1,
        'events': <Map<String, Object?>>[
          for (int i = 0; i < 200; i++)
            <String, Object?>{
              'id': 'event-$i',
              'hlc': '000000001723456789-00000-device',
              'deviceId': 'device',
              'type': 3,
              'payload': <String, Object?>{
                'entryId': 'entry-$i',
                'description': 'راشن',
                'amountMinor': 250000 + i,
              },
            },
        ],
      });

      final enc.Encrypter encrypter = encrypterFor('hamara ghar', salt);
      final enc.Encrypted sealed =
          encrypter.encryptBytes(utf8.encode(json), iv: enc.IV(nonce));
      final String opened =
          utf8.decode(encrypter.decryptBytes(sealed, iv: enc.IV(nonce)));

      final Map<String, Object?> decoded =
          jsonDecode(opened) as Map<String, Object?>;
      expect((decoded['events']! as List<Object?>).length, 200);
      // Urdu survives the trip intact.
      expect(opened, contains('راشن'));
    });
  });
}
