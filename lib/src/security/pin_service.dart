import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../domain/ledger_repository.dart';

/// The app's screen lock.
///
/// What this is actually for: a shared phone. Research on women's phone use in
/// South Asia is blunt about it — many women do not own the handset outright,
/// and the household ledger is exactly the kind of thing someone would rather
/// not have read over their shoulder. The threat here is a family member
/// picking up the phone, not a forensic analyst.
///
/// So the PIN is stretched with PBKDF2 and stored as a hash beside a random
/// salt, never in plaintext. That is honest protection against the threat it is
/// meant for. It is *not* encryption of the ledger itself — a four-digit PIN
/// only has ten thousand possibilities, so anyone who can pull the database
/// file off the device can brute-force it in moments. Real at-rest encryption
/// is a Stage 4 job; what keeps the file out of reach today is Android's
/// private app storage.
class PinService {
  PinService(this._ledger);

  final LedgerRepository _ledger;

  static const String _saltKey = 'security.pin_salt';
  static const String _hashKey = 'security.pin_hash';

  /// Enough to make a wrong guess cost real time, while an unlock on a budget
  /// phone still feels immediate.
  static const int _iterations = 20000;

  static final Random _random = Random.secure();

  Future<bool> isSet() async => (await _ledger.readMeta(_hashKey)) != null;

  Future<void> setPin(String pin) async {
    final List<int> salt =
        List<int>.generate(16, (_) => _random.nextInt(256));
    final List<int> hash = _derive(pin, salt);
    await _ledger.writeMeta(_saltKey, base64Encode(salt));
    await _ledger.writeMeta(_hashKey, base64Encode(hash));
  }

  Future<bool> verify(String pin) async {
    final String? saltText = await _ledger.readMeta(_saltKey);
    final String? hashText = await _ledger.readMeta(_hashKey);
    if (saltText == null || hashText == null) return true;

    final List<int> expected = base64Decode(hashText);
    final List<int> actual = _derive(pin, base64Decode(saltText));
    return _constantTimeEquals(expected, actual);
  }

  Future<void> clear() async {
    await _ledger.deleteMeta(_saltKey);
    await _ledger.deleteMeta(_hashKey);
  }

  /// PBKDF2-HMAC-SHA256, single output block (32 bytes is all we need).
  static List<int> _derive(String pin, List<int> salt) {
    final Hmac hmac = Hmac(sha256, utf8.encode(pin));

    // First iteration runs over salt || INT(1), per the PBKDF2 spec.
    List<int> u = hmac.convert(<int>[...salt, 0, 0, 0, 1]).bytes;
    final List<int> result = List<int>.of(u);

    for (int i = 1; i < _iterations; i++) {
      u = hmac.convert(u).bytes;
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    return result;
  }

  /// Compares every byte regardless of where the first difference is, so the
  /// time taken says nothing about how much of the guess was right.
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int difference = 0;
    for (int i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}
