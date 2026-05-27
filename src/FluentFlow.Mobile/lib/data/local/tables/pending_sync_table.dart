import 'package:drift/drift.dart';

@DataClassName('PendingSyncData')
class PendingSyncTable extends Table {
  IntColumn    get id        => integer().autoIncrement()();
  TextColumn   get operation => text()();
  TextColumn   get payload   => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn    get retryCount  => integer().withDefault(const Constant(0))();

  @override
  String get tableName => 'pending_sync';
}