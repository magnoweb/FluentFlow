import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/card_table.dart';

part 'card_dao.g.dart';

@DriftAccessor(tables: [CardTable])
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  /// Todos os cards activos de um deck
  Future<List<CardTableData>> getByDeck(String deckId) => (select(
    cardTable,
  )..where((c) => c.deckId.equals(deckId) & c.isActive.equals(true))).get();

  /// Cards para o plano de hoje
  Future<List<CardTableData>> getDueCards(
    String deckId,
    String mode,
    int maxNew,
    int maxReview,
  ) async {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final all = await getByDeck(deckId);

    final List<CardTableData> overdue;
    final List<CardTableData> due;
    final List<CardTableData> newCards;

    if (mode == 'Listening') {
      // Overdue: nextReview existe e é anterior a hoje
      overdue = all
          .where(
            (c) =>
                c.listeningNextReview != null &&
                c.listeningNextReview!.toUtc().isBefore(today),
          )
          .toList();

      // Due hoje: nextReview >= início do dia e < início de amanhã
      due = all
          .where(
            (c) =>
                c.listeningNextReview != null &&
                !c.listeningNextReview!.toUtc().isBefore(today) &&
                c.listeningNextReview!.toUtc().isBefore(tomorrow),
          )
          .toList();

      // Novos: nunca foram estudados em Listening (nextReview == null)
      // Não confundir com cards novos para Speaking — são independentes
      newCards = all
          .where(
            (c) => c.listeningNextReview == null && c.listeningRepetitions == 0,
          )
          .toList();
    } else {
      overdue = all
          .where(
            (c) =>
                c.speakingNextReview != null &&
                c.speakingNextReview!.toUtc().isBefore(today),
          )
          .toList();

      due = all
          .where(
            (c) =>
                c.speakingNextReview != null &&
                !c.speakingNextReview!.toUtc().isBefore(today) &&
                c.speakingNextReview!.toUtc().isBefore(tomorrow),
          )
          .toList();

      // Novos para Speaking: nunca foram estudados em Speaking
      newCards = all
          .where(
            (c) => c.speakingNextReview == null && c.speakingRepetitions == 0,
          )
          .toList();
    }

    return [...overdue, ...due.take(maxReview), ...newCards.take(maxNew)];
  }

  /// Cards estudados hoje (para dashboard local — fallback offline)
  Future<int> countStudiedToday(String deckId, String mode) async {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final all = await getByDeck(deckId);

    // Card estudado hoje = updatedAt >= início do dia de hoje UTC
    // E tem pelo menos 1 repetição no modo pedido
    if (mode == 'Listening') {
      return all
          .where(
            (c) =>
                c.listeningRepetitions > 0 &&
                    c.updatedAt.toUtc().isAfter(today) ||
                c.updatedAt.toUtc().isAtSameMomentAs(today),
          )
          .length;
    } else {
      return all
          .where(
            (c) =>
                c.speakingRepetitions > 0 &&
                    c.updatedAt.toUtc().isAfter(today) ||
                c.updatedAt.toUtc().isAtSameMomentAs(today),
          )
          .length;
    }
  }

  /// Inserir ou actualizar um card — preservar updatedAt se vier da API
  Future<void> upsertCard(CardTableCompanion card) =>
      into(cardTable).insertOnConflictUpdate(card);

  /// Inserir ou actualizar múltiplos cards da API
  /// IMPORTANTE: usa o updatedAt da API, não DateTime.now()
  Future<void> upsertAll(List<CardTableCompanion> cards) =>
      batch((b) => b.insertAllOnConflictUpdate(cardTable, cards));

  /// Inserir ou actualizar múltiplos cards preservando SM-2 local
  /// Usado ao sincronizar da API — não sobrescreve dados SM-2 mais recentes
  Future<void> upsertAllPreservingLocal(List<CardTableCompanion> cards) async {
    for (final card in cards) {
      final existing = await (select(
        cardTable,
      )..where((c) => c.id.equals(card.id.value))).getSingleOrNull();

      if (existing == null) {
        // Card novo — inserir directamente
        await into(cardTable).insertOnConflictUpdate(card);
      } else {
        // Card existente — preservar dados SM-2 locais se mais recentes
        final apiUpdatedAt = card.updatedAt.value;
        final localUpdatedAt = existing.updatedAt;

        if (localUpdatedAt.isAfter(apiUpdatedAt)) {
          // Local é mais recente (review offline) — preservar SM-2
          // Actualizar apenas metadados do card (front, back, audio, etc.)
          await (update(
            cardTable,
          )..where((c) => c.id.equals(card.id.value))).write(
            CardTableCompanion(
              front: card.front,
              back: card.back,
              pronunciation: card.pronunciation,
              audioPath: card.audioPath,
              isActive: card.isActive,
              // SM-2 e updatedAt preservados do local
            ),
          );
        } else {
          // API é mais recente — actualizar tudo incluindo SM-2
          await into(cardTable).insertOnConflictUpdate(card);
        }
      }
    }
  }

  /// Aplicar SM-2 localmente — sempre em UTC
  Future<void> applySM2(String cardId, String mode, int score) async {
    final card = await (select(
      cardTable,
    )..where((c) => c.id.equals(cardId))).getSingleOrNull();

    if (card == null) return;

    final companion = _computeSM2(card, mode, score);
    await (update(
      cardTable,
    )..where((c) => c.id.equals(cardId))).write(companion);
  }

  CardTableCompanion _computeSM2(CardTableData card, String mode, int score) {
    // Sempre UTC — consistente com a API e com getDueCards
    final now = DateTime.now().toUtc();

    int reps;
    double ef;
    int interval;

    if (mode == 'Listening') {
      reps = card.listeningRepetitions;
      ef = card.listeningEaseFactor;
      interval = card.listeningInterval;
    } else {
      reps = card.speakingRepetitions;
      ef = card.speakingEaseFactor;
      interval = card.speakingInterval;
    }

    // SM-2
    if (score < 3) {
      reps = 0;
      interval = 1;
    } else {
      interval = reps == 0
          ? 1
          : reps == 1
          ? 6
          : (interval * ef).round();
      reps++;
    }
    ef = (ef + (0.1 - (5 - score) * (0.08 + (5 - score) * 0.02))).clamp(
      1.3,
      5.0,
    );

    // nextReview = início do dia UTC + interval dias
    // Garante que a comparação em getDueCards funciona correctamente
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final nextReview = todayUtc.add(Duration(days: interval));

    if (mode == 'Listening') {
      return CardTableCompanion(
        listeningRepetitions: Value(reps),
        listeningEaseFactor: Value(ef),
        listeningInterval: Value(interval),
        listeningNextReview: Value(nextReview),
        updatedAt: Value(now), // UTC
      );
    } else {
      return CardTableCompanion(
        speakingRepetitions: Value(reps),
        speakingEaseFactor: Value(ef),
        speakingInterval: Value(interval),
        speakingNextReview: Value(nextReview),
        updatedAt: Value(now), // UTC
      );
    }
  }
}
