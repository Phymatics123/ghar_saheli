import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Name of the database file inside the app's private documents directory.
///
/// Private storage, not external storage: the ledger never leaves the phone
/// and is not readable by other apps or by anyone browsing the SD card.
const String kDatabaseFileName = 'ghar_saheli.sqlite';

/// Opens the database lazily on a background isolate.
///
/// `createInBackground` keeps every query off the UI thread. On a budget
/// phone the difference between a jank-free list and a stuttering one is
/// mostly this one decision.
QueryExecutor openLocalDatabase() {
  return LazyDatabase(() async {
    final Directory folder = await getApplicationDocumentsDirectory();
    final File file = File(p.join(folder.path, kDatabaseFileName));
    return NativeDatabase.createInBackground(file);
  });
}

/// In-memory database for tests. No file, no permissions, no cleanup.
QueryExecutor openInMemoryDatabase() => NativeDatabase.memory();
