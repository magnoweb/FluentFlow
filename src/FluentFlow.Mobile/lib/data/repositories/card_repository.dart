import 'package:drift/drift.dart';

import '../local/database.dart';
import '../remote/api_client.dart';
import '../dto/card_dto.dart';

class CardRepository {
  final ApiClient _api;
  final AppDatabase _db;

  CardRepository(this._api, this._db);

  Future<List<CardDto>> getCards(String deckId) async {
    try {
      final data = await _api.getCards(deckId);
      final cards = (data['items'] as List)
          .map((e) => CardDto.fromJson(e as Map<String, dynamic>))
          .toList();

      // Persistir localmente
      await _db.cardDao.upsertAll(
        cards
            .map(
              (c) => CardTableCompanion(
                id: Value(c.id),
                deckId: Value(c.deckId),
                front: Value(c.front),
                back: Value(c.back),
                pronunciation: Value(c.pronunciation),
                audioPath: Value(c.audioPath),
                listeningRepetitions: Value(c.listeningRepetitions),
                listeningEaseFactor: const Value(2.5),
                listeningInterval: Value(c.listeningInterval),
                listeningNextReview: Value(c.listeningNextReview),
                speakingRepetitions: Value(c.speakingRepetitions),
                speakingEaseFactor: const Value(2.5),
                speakingInterval: Value(c.speakingInterval),
                speakingNextReview: Value(c.speakingNextReview),
                isActive: const Value(true),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            )
            .toList(),
      );

      return cards;
    } catch (_) {
      final local = await _db.cardDao.getByDeck(deckId);
      return local.map(_toDto).toList();
    }
  }

  CardDto _toDto(CardTableData c) => CardDto.fromJson({
    'id': c.id,
    'deckId': c.deckId,
    'front': c.front,
    'back': c.back,
    'pronunciation': c.pronunciation,
    'audioPath': c.audioPath,
    'listeningRepetitions': c.listeningRepetitions,
    'listeningInterval': c.listeningInterval,
    'listeningNextReview': c.listeningNextReview?.toIso8601String(),
    'speakingRepetitions': c.speakingRepetitions,
    'speakingInterval': c.speakingInterval,
    'speakingNextReview': c.speakingNextReview?.toIso8601String(),
  });
}
