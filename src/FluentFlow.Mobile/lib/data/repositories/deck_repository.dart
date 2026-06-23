import 'package:drift/drift.dart';

import '../dto/study_dto.dart';
import '../local/database.dart';
import '../remote/api_client.dart';
import '../dto/deck_dto.dart';

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
      // Offline — calcular localmente a partir do SQLite
      final cards = await _db.cardDao.getByDeck(deckId);
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final totalCards = cards.length;
      final studiedToday = await _db.cardDao.countStudiedToday(
        deckId,
        'Listening',
      );
      final dueToday = cards
          .where(
            (c) =>
                c.listeningNextReview != null &&
                c.listeningNextReview!.toUtc().isBefore(tomorrow),
          )
          .length;
      final newToday = cards
          .where(
            (c) => c.listeningNextReview == null && c.listeningRepetitions == 0,
          )
          .length;

      return DashboardDto.fromJson({
        'totalCards': totalCards,
        'dueToday': dueToday,
        'newToday': newToday,
        'studiedToday': studiedToday,
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
