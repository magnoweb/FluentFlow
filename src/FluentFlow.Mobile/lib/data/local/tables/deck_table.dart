import 'package:drift/drift.dart';

@DataClassName('DeckTableData')
class DeckTable extends Table {
  TextColumn   get id               => text()();
  TextColumn   get userId           => text()();
  TextColumn   get name             => text()();
  TextColumn   get description      => text().nullable()();
  TextColumn   get language         => text()();
  TextColumn   get nativeLanguage   => text()();
  IntColumn    get maxNewCardsPerDay => integer().withDefault(const Constant(20))();
  IntColumn    get maxReviewsPerDay  => integer().withDefault(const Constant(100))();
  BoolColumn   get isActive          => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt       => dateTime()();
  DateTimeColumn get updatedAt       => dateTime()();
  DateTimeColumn get lastSyncAt      => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'deck_table';
}