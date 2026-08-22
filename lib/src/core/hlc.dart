/// Hybrid Logical Clock.
///
/// Wall clocks on cheap phones drift, get set by hand, and jump when the
/// network time kicks in. If two phones in one household ever exchange
/// ledger events, ordering them by `DateTime.now()` would eventually put a
/// later edit before an earlier one and silently corrupt the ledger.
///
/// An HLC keeps a physical component (so ordering still roughly matches real
/// time and is readable by a human) and a logical counter (so ordering stays
/// correct even when the physical clock lies). Ties break on device id, which
/// makes the total order identical on every device — the property that lets
/// two phones converge without a server refereeing.
///
/// Nothing in Stage 0 syncs yet. This exists now because retrofitting causal
/// ordering onto a ledger that was already written with naive timestamps
/// means rewriting history.
class Hlc implements Comparable<Hlc> {
  const Hlc(this.millis, this.counter, this.nodeId);

  /// Physical time in milliseconds since epoch.
  final int millis;

  /// Logical counter, incremented when several events share a millisecond
  /// or when a remote event arrives from the future.
  final int counter;

  /// Stable id of the device that stamped this. Also the tiebreaker.
  final String nodeId;

  /// A remote clock further ahead than this is treated as broken rather than
  /// trusted, so one phone with a wrong date cannot drag the whole household
  /// ledger into the future.
  static const int maxDriftMillis = 5 * 60 * 1000;

  factory Hlc.zero(String nodeId) => Hlc(0, 0, nodeId);

  factory Hlc.parse(String packed) {
    final int firstDash = packed.indexOf('-');
    final int secondDash = packed.indexOf('-', firstDash + 1);
    if (firstDash < 0 || secondDash < 0) {
      throw FormatException('Not an HLC: $packed');
    }
    return Hlc(
      int.parse(packed.substring(0, firstDash)),
      int.parse(packed.substring(firstDash + 1, secondDash)),
      packed.substring(secondDash + 1),
    );
  }

  /// Fixed-width so plain string comparison matches [compareTo]. That lets
  /// SQLite sort the event log with an ordinary index on a TEXT column.
  String get packed =>
      '${millis.toString().padLeft(15, '0')}-'
      '${counter.toString().padLeft(5, '0')}-'
      '$nodeId';

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(millis);

  /// Stamps a locally generated event.
  Hlc tick(int nowMillis) {
    if (nowMillis > millis) return Hlc(nowMillis, 0, nodeId);
    return Hlc(millis, counter + 1, nodeId);
  }

  /// Folds in a clock read from another device.
  Hlc merge(Hlc remote, int nowMillis) {
    if (remote.millis - nowMillis > maxDriftMillis) {
      throw StateError(
        'Remote clock is ${remote.millis - nowMillis}ms ahead; refusing to merge.',
      );
    }
    if (nowMillis > millis && nowMillis > remote.millis) {
      return Hlc(nowMillis, 0, nodeId);
    }
    if (millis == remote.millis) {
      return Hlc(millis, (counter > remote.counter ? counter : remote.counter) + 1, nodeId);
    }
    if (millis > remote.millis) {
      return Hlc(millis, counter + 1, nodeId);
    }
    return Hlc(remote.millis, remote.counter + 1, nodeId);
  }

  @override
  int compareTo(Hlc other) {
    final int byMillis = millis.compareTo(other.millis);
    if (byMillis != 0) return byMillis;
    final int byCounter = counter.compareTo(other.counter);
    if (byCounter != 0) return byCounter;
    return nodeId.compareTo(other.nodeId);
  }

  bool operator >(Hlc other) => compareTo(other) > 0;
  bool operator <(Hlc other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.millis == millis &&
      other.counter == counter &&
      other.nodeId == nodeId;

  @override
  int get hashCode => Object.hash(millis, counter, nodeId);

  @override
  String toString() => packed;
}

/// Holds the current [Hlc] for this device.
///
/// The caller is responsible for persisting [current] alongside each event it
/// writes — see `LedgerRepository.applyEvent`, which does it inside the same
/// database transaction so the clock can never advance without the event that
/// advanced it also landing.
class HlcClock {
  HlcClock({required String nodeId, Hlc? restored})
      : _current = restored ?? Hlc.zero(nodeId);

  Hlc _current;

  Hlc get current => _current;

  /// Advances and returns the stamp for a new local event.
  Hlc issue() {
    _current = _current.tick(DateTime.now().millisecondsSinceEpoch);
    return _current;
  }

  /// Advances past an event received from another device.
  Hlc witness(Hlc remote) {
    _current = _current.merge(remote, DateTime.now().millisecondsSinceEpoch);
    return _current;
  }
}
