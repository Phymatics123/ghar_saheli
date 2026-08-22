import 'package:drift/drift.dart';

import 'core/hlc.dart';
import 'core/ulid.dart';
import 'data/connection.dart';
import 'data/database.dart';
import 'domain/ledger_repository.dart';

/// Boots the local engine and hands back a ready [LedgerRepository].
///
/// Everything below the UI is assembled here, and only here, so screens never
/// construct a database or a clock themselves.
class GharSaheliEngine {
  GharSaheliEngine._({
    required this.database,
    required this.ledger,
    required this.deviceId,
  });

  final AppDatabase database;
  final LedgerRepository ledger;

  /// Stable per-install identity. Not a user identity — nothing about the
  /// person, nothing that leaves the phone. It exists so that when two phones
  /// in one household eventually exchange events, their clocks can be ordered
  /// against each other.
  final String deviceId;

  /// Opens the database, restores the clock, seeds default categories.
  ///
  /// [executor] is injectable so tests can run against an in-memory database.
  static Future<GharSaheliEngine> boot({QueryExecutor? executor}) async {
    final AppDatabase database = AppDatabase(executor ?? openLocalDatabase());

    final String deviceId = await _restoreOrCreateDeviceId(database);
    final Hlc? restoredClock = await _restoreClock(database, deviceId);

    final LedgerRepository ledger = LedgerRepository(
      database: database,
      clock: HlcClock(nodeId: deviceId, restored: restoredClock),
      deviceId: deviceId,
    );

    await ledger.ensureSeeded();

    return GharSaheliEngine._(
      database: database,
      ledger: ledger,
      deviceId: deviceId,
    );
  }

  Future<void> close() => database.close();

  static Future<String> _restoreOrCreateDeviceId(AppDatabase database) async {
    final AppMetaRow? row = await (database.select(database.appMeta)
          ..where((AppMeta m) => m.key.equals(MetaKeys.deviceId)))
        .getSingleOrNull();
    if (row != null) return row.value;

    final String created = Ulid.generate();
    await database.into(database.appMeta).insert(
          AppMetaRow(key: MetaKeys.deviceId, value: created),
        );
    return created;
  }

  static Future<Hlc?> _restoreClock(
    AppDatabase database,
    String deviceId,
  ) async {
    final AppMetaRow? row = await (database.select(database.appMeta)
          ..where((AppMeta m) => m.key.equals(MetaKeys.lastHlc)))
        .getSingleOrNull();
    if (row == null) return null;

    try {
      final Hlc stored = Hlc.parse(row.value);
      // Adopt the stored time but keep this device's own id as the node,
      // so a restored-from-backup database cannot make this phone start
      // stamping events under another device's identity.
      return Hlc(stored.millis, stored.counter, deviceId);
    } on FormatException {
      // A corrupt clock value is recoverable — worst case the next event
      // starts from wall time again.
      return null;
    }
  }
}
