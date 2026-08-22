import 'dart:math';

/// Crockford base32 — skips I, L, O and U so IDs can be read aloud or
/// retyped without ambiguity.
const String _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Generates 26-character ULIDs: 10 chars of timestamp + 16 chars of
/// randomness.
///
/// Chosen over UUIDv4 for two reasons that matter to this app:
///  * IDs sort chronologically as plain strings, so the event log can be
///    ordered without reading a separate timestamp column.
///  * No extra package, which keeps the APK small.
class Ulid {
  Ulid._();

  static final Random _rng = Random.secure();
  static int _lastMillis = -1;
  static final List<int> _lastRandom = List<int>.filled(16, 0);

  /// Returns a new ULID. Two calls in the same millisecond stay ordered
  /// because the random tail is incremented rather than re-rolled.
  static String generate([DateTime? at]) {
    final int millis = (at ?? DateTime.now()).millisecondsSinceEpoch;

    if (millis == _lastMillis) {
      _incrementRandom();
    } else {
      _lastMillis = millis;
      for (int i = 0; i < 16; i++) {
        _lastRandom[i] = _rng.nextInt(32);
      }
    }

    final List<String> chars = List<String>.filled(26, '0');
    int remaining = millis;
    for (int i = 9; i >= 0; i--) {
      chars[i] = _alphabet[remaining & 31];
      remaining = remaining >> 5;
    }
    for (int i = 0; i < 16; i++) {
      chars[10 + i] = _alphabet[_lastRandom[i]];
    }
    return chars.join();
  }

  /// Carries through the random tail so ordering holds inside one millisecond.
  static void _incrementRandom() {
    for (int i = 15; i >= 0; i--) {
      if (_lastRandom[i] < 31) {
        _lastRandom[i]++;
        return;
      }
      _lastRandom[i] = 0;
    }
  }

  /// Reads the timestamp back out of a ULID. Useful for debugging the log.
  static DateTime timestampOf(String ulid) {
    int millis = 0;
    for (int i = 0; i < 10; i++) {
      final int value = _alphabet.indexOf(ulid[i]);
      if (value < 0) throw FormatException('Not a ULID: $ulid');
      millis = (millis << 5) | value;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }
}
