import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/deck_table.dart';
import 'tables/card_table.dart';
import 'tables/pending_sync_table.dart';
import 'daos/deck_dao.dart';
import 'daos/card_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [DeckTable, CardTable, PendingSyncTable],
  daos:   [DeckDao, CardDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {},
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir  = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'fluentflow.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// Provider global
final databaseProvider = Provider<AppDatabase>((_) => AppDatabase());