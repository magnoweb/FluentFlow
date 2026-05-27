import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/card_table.dart';

part 'card_dao.g.dart';

@DriftAccessor(tables: [CardTable])
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  /// Todos os cards activos de um deck
  Future<List<CardTableData>> getByDeck(String deckId) =>
      (select(cardTable)
        ..where((c) =>
        c.deckId.equals(deckId) & c.isActive.equals(true)))
          .get();

  /// Cards para o plano de hoje
  Future<List<CardTableData>> getDueCards(
      String deckId,
      String mode,
      int maxNew,
      int maxReview,
      ) async {
    final now      = DateTime.now().toUtc();
    final today    = DateTime.utc(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final all      = await getByDeck(deckId);

    final List<CardTableData> overdue;
    final List<CardTableData> due;
    final List<CardTableData> newCards;

    if (mode == 'Listening') {
      overdue  = all.where((c) =>
      c.listeningNextReview != null &&
          c.listeningNextReview!.isBefore(today)).toList();
      due      = all.where((c) =>
      c.listeningNextReview != null &&
          !c.listeningNextReview!.isBefore(today) &&
          c.listeningNextReview!.isBefore(tomorrow)).toList();
      newCards = all.where((c) =>
      c.listeningRepetitions == 0).toList();
    } else {
      overdue  = all.where((c) =>
      c.speakingNextReview != null &&
          c.speakingNextReview!.isBefore(today)).toList();
      due      = all.where((c) =>
      c.speakingNextReview != null &&
          !c.speakingNextReview!.isBefore(today) &&
          c.speakingNextReview!.isBefore(tomorrow)).toList();
      newCards = all.where((c) =>
      c.speakingRepetitions == 0).toList();
    }

    return [
      ...overdue,
      ...due.take(maxReview),
      ...newCards.take(maxNew),
    ];
  }

  /// Inserir ou actualizar um card
  Future<void> upsertCard(CardTableCompanion card) =>
      into(cardTable).insertOnConflictUpdate(card);

  /// Inserir ou actualizar múltiplos cards de uma vez
  Future<void> upsertAll(List<CardTableCompanion> cards) =>
      batch((b) => b.insertAllOnConflictUpdate(cardTable, cards));

  /// Aplicar SM-2 localmente
  Future<void> applySM2(String cardId, String mode, int score) async {
    final card = await (select(cardTable)
      ..where((c) => c.id.equals(cardId)))
        .getSingleOrNull();

    if (card == null) return;

    final companion = _computeSM2(card, mode, score);
    await (update(cardTable)
      ..where((c) => c.id.equals(cardId)))
        .write(companion);
  }

  CardTableCompanion _computeSM2(
      CardTableData card, String mode, int score) {
    final now = DateTime.now().toUtc();

    int    reps;
    double ef;
    int    interval;

    if (mode == 'Listening') {
      reps     = card.listeningRepetitions;
      ef       = card.listeningEaseFactor;
      interval = card.listeningInterval;
    } else {
      reps     = card.speakingRepetitions;
      ef       = card.speakingEaseFactor;
      interval = card.speakingInterval;
    }

    // SM-2
    if (score < 3) {
      reps     = 0;
      interval = 1;
    } else {
      interval = reps == 0 ? 1 : reps == 1 ? 6 : (interval * ef).round();
      reps++;
    }
    ef = (ef + (0.1 - (5 - score) * (0.08 + (5 - score) * 0.02)))
        .clamp(1.3, 5.0);

    final nextReview = now.add(Duration(days: interval));

    if (mode == 'Listening') {
      return CardTableCompanion(
        listeningRepetitions: Value(reps),
        listeningEaseFactor:  Value(ef),
        listeningInterval:    Value(interval),
        listeningNextReview:  Value(nextReview),
        updatedAt:            Value(now),
      );
    } else {
      return CardTableCompanion(
        speakingRepetitions: Value(reps),
        speakingEaseFactor:  Value(ef),
        speakingInterval:    Value(interval),
        speakingNextReview:  Value(nextReview),
        updatedAt:           Value(now),
      );
    }
  }
}