import 'package:drift/drift.dart';

@DataClassName('CardTableData')
class CardTable extends Table {
  TextColumn   get id            => text()();
  TextColumn   get deckId        => text()();
  TextColumn   get front         => text()();
  TextColumn   get back          => text()();
  TextColumn   get pronunciation => text().nullable()();
  TextColumn   get audioPath     => text().nullable()();
  TextColumn   get cefrLevel     => text().nullable()();

  IntColumn    get listeningRepetitions => integer().withDefault(const Constant(0))();
  RealColumn   get listeningEaseFactor  => real().withDefault(const Constant(2.5))();
  IntColumn    get listeningInterval    => integer().withDefault(const Constant(0))();
  DateTimeColumn get listeningNextReview => dateTime().nullable()();

  IntColumn    get speakingRepetitions => integer().withDefault(const Constant(0))();
  RealColumn   get speakingEaseFactor  => real().withDefault(const Constant(2.5))();
  IntColumn    get speakingInterval    => integer().withDefault(const Constant(0))();
  DateTimeColumn get speakingNextReview => dateTime().nullable()();

  BoolColumn   get isActive  => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'card_table';
}