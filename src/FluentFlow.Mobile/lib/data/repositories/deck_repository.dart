import 'package:drift/drift.dart';

import '../dto/study_dto.dart';
import '../local/database.dart';
import '../remote/api_client.dart';
import '../dto/deck_dto.dart';
import '../../core/services/audio_prefs.dart';

class DeckRepository {
  final ApiClient _api;
  final AppDatabase _db;

  DeckRepository(this._api, this._db);

  Future<List<DeckDto>> getDecks({bool forceRemote = false}) async {
    // Tentar remoto primeiro
    try {
      final data = await _api.getDecks(pageSize: 200);
      final paged = PagedDecksDto.fromJson(data);

      // Persistir localmente
      for (final d in paged.items) {
        await AudioPrefs.setDeckRepeatCount(d.id, d.listeningRepeatCount);
        await _db.deckDao.upsertDeck(
          DeckTableCompanion(
            id: Value(d.id),
            userId: const Value(''),
            name: Value(d.name),
            description: Value(d.description),
            language: Value(d.language),
            nativeLanguage: Value(d.nativeLanguage),
            maxNewCardsPerDay: Value(d.maxNewCardsPerDay),
            maxReviewsPerDay: Value(d.maxReviewsPerDay),
            isActive: const Value(true),
            createdAt: Value(d.createdAt),
            updatedAt: Value(DateTime.now().toUtc()),
            lastSyncAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
      return paged.items;
    } catch (_) {
      // Fallback para local
      final local = await _db.deckDao.getAll();
      return local.map(_toDto).toList();
    }
  }

  Future<DashboardDto?> getDashboard(String deckId) async {
    try {
      final data = await _api.getDashboard(deckId);
      return DashboardDto.fromJson(data);
    } catch (_) {
      // Offline — calcular localmente a partir do SQLite, espelhando exactamente a
      // mesma lógica do backend (StudySchedulerService.GetAvailableCards), por modo,
      // unindo Listening + Speaking. Garante que o número bate certo com o que a
      // sessão de estudo (CardDao.getDueCards) efectivamente oferece offline.
      final cards = await _db.cardDao.getByDeck(deckId);
      final deck = await _db.deckDao.getById(deckId);
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final maxNewCardsPerDay = deck?.maxNewCardsPerDay ?? 0;
      final maxReviewsPerDay = deck?.maxReviewsPerDay ?? 0;

      final studiedCardIds = <String>{};
      final dueCardIds = <String>{};
      final newCardIds = <String>{};

      for (final mode in ['Listening', 'Speaking']) {
        final isListening = mode == 'Listening';

        DateTime? nextReview(CardTableData c) =>
            isListening ? c.listeningNextReview : c.speakingNextReview;
        int repetitions(CardTableData c) =>
            isListening ? c.listeningRepetitions : c.speakingRepetitions;

        // Estudados hoje neste modo = tem repetições > 0 e foi actualizado hoje
        final studiedTodayModeIds = cards
            .where(
              (c) =>
                  repetitions(c) > 0 &&
                  (c.updatedAt.toUtc().isAfter(today) ||
                      c.updatedAt.toUtc().isAtSameMomentAs(today)),
            )
            .map((c) => c.id)
            .toSet();
        studiedCardIds.addAll(studiedTodayModeIds);

        // Overdue — nunca cortado por maxReviewsPerDay (ver nota no backend/CardDao)
        final overdue = cards.where(
          (c) =>
              nextReview(c) != null &&
              nextReview(c)!.toUtc().isBefore(today) &&
              !studiedTodayModeIds.contains(c.id),
        );

        final due = cards
            .where(
              (c) =>
                  nextReview(c) != null &&
                  !nextReview(c)!.toUtc().isBefore(today) &&
                  nextReview(c)!.toUtc().isBefore(tomorrow) &&
                  !studiedTodayModeIds.contains(c.id),
            )
            .toList();

        final reviewSlots = (maxReviewsPerDay - studiedTodayModeIds.length) < 0
            ? 0
            : maxReviewsPerDay - studiedTodayModeIds.length;

        dueCardIds.addAll(overdue.map((c) => c.id));
        dueCardIds.addAll(due.take(reviewSlots).map((c) => c.id));

        final newForMode = cards
            .where(
              (c) =>
                  repetitions(c) == 0 &&
                  nextReview(c) == null &&
                  !studiedTodayModeIds.contains(c.id),
            )
            .take(maxNewCardsPerDay);
        newCardIds.addAll(newForMode.map((c) => c.id));
      }

      return DashboardDto.fromJson({
        'totalCards': cards.length,
        'dueToday': dueCardIds.length,
        'newToday': newCardIds.length,
        'studiedToday': studiedCardIds.length,
        'averageEaseFactor': 2.5,
        'last30Days': [],
      });
    }
  }

  DeckDto _toDto(DeckTableData d) => DeckDto.fromJson({
    'id': d.id,
    'name': d.name,
    'description': d.description,
    'language': d.language,
    'nativeLanguage': d.nativeLanguage,
    'maxNewCardsPerDay': d.maxNewCardsPerDay,
    'maxReviewsPerDay': d.maxReviewsPerDay,
    'totalCards': 0,
    'createdAt': d.createdAt.toIso8601String(),
  });
}
