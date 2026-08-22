import 'dart:convert';

import '../core/hlc.dart';

/// Every change to the ledger is one of these.
///
/// Stored as the enum index — append only, never reorder.
enum LedgerEventType {
  accountCreated,
  accountUpdated,
  accountArchived,
  entryRecorded,
  entryVoided,

  // Added in Stage 2. Appended rather than slotted in beside the account
  // events, because every event already written to a user's phone stores this
  // enum's index — reordering would silently reinterpret their history.
  templateSaved,
  templateRemoved,
  templateConfirmed,

  // Added in Stage 3, appended for the same reason.
  staffSaved,
  staffRemoved,
  attendanceMarked,
  attendanceCleared,

  /// Many days at once. Its own type rather than a loop of single marks so a
  /// month fills in one database transaction instead of thirty.
  attendanceRangeMarked,
}

/// An immutable fact about something that happened, plus enough metadata to
/// order it against facts recorded on another device.
///
/// The ledger tables are a *projection* of these. Writes go through
/// `LedgerRepository.applyEvent`, which appends the envelope and mutates the
/// tables in one database transaction. When Stage 4 adds family sync, a
/// remote envelope takes the exact same path — there is no second code path
/// that can drift out of step with the local one.
class LedgerEvent {
  const LedgerEvent({
    required this.id,
    required this.hlc,
    required this.deviceId,
    required this.type,
    required this.payload,
  });

  /// ULID. Also the idempotency key: applying the same event twice is a no-op,
  /// which is what makes re-syncing safe.
  final String id;

  final Hlc hlc;
  final String deviceId;
  final LedgerEventType type;
  final Map<String, Object?> payload;

  String get payloadJson => jsonEncode(payload);

  factory LedgerEvent.fromRow({
    required String id,
    required String hlcPacked,
    required String deviceId,
    required int type,
    required String payloadJson,
  }) {
    return LedgerEvent(
      id: id,
      hlc: Hlc.parse(hlcPacked),
      deviceId: deviceId,
      type: LedgerEventType.values[type],
      payload: jsonDecode(payloadJson) as Map<String, Object?>,
    );
  }

  Map<String, Object?> toWireJson() => <String, Object?>{
        'id': id,
        'hlc': hlc.packed,
        'deviceId': deviceId,
        'type': type.index,
        'payload': payload,
      };

  factory LedgerEvent.fromWireJson(Map<String, Object?> json) {
    return LedgerEvent(
      id: json['id']! as String,
      hlc: Hlc.parse(json['hlc']! as String),
      deviceId: json['deviceId']! as String,
      type: LedgerEventType.values[json['type']! as int],
      payload: (json['payload'] as Map?)?.cast<String, Object?>() ??
          const <String, Object?>{},
    );
  }

  @override
  String toString() => 'LedgerEvent(${type.name} @ ${hlc.packed})';
}
