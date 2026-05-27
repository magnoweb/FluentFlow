import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/deck_table.dart';

part 'deck_dao.g.dart';

@DriftAccessor(tables: [DeckTable])
class DeckDao extends DatabaseAccessor<AppDatabase> with _$DeckDaoMixin {
  DeckDao(super.db);

  /// Todos os decks activos ordenados por data de criação
  Future<List<DeckTableData>> getAll() =>
      (select(deckTable)
        ..where((d) => d.isActive.equals(true))
        ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
          .get();

  /// Deck por ID
  Future<DeckTableData?> getById(String id) =>
      (select(deckTable)..where((d) => d.id.equals(id)))
          .getSingleOrNull();

  /// Inserir ou actualizar
  Future<void> upsertDeck(DeckTableCompanion deck) =>
      into(deckTable).insertOnConflictUpdate(deck);

  /// Apagar todos (para reset)
  Future<void> deleteAll() => delete(deckTable).go();
}