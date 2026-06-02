import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../data/remote/api_client.dart';
import '../../features/auth/auth_provider.dart' hide databaseProvider;

class SyncService {
  final AppDatabase _db;
  final ApiClient   _api;

  SyncService(this._db, this._api);

  // Chamado quando a app detects ligação restaurada
  Future<void> syncPendingOperations() async {
    final pending = await _db.select(_db.pendingSyncTable).get();
    if (pending.isEmpty) return;

    for (final item in pending) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;

        switch (item.operation) {
          case 'submitReview':
            await _api.submitReview(
              sessionId:       payload['sessionId'] as String,
              cardId:          payload['cardId']    as String,
              score:           payload['score']     as int,
              similarityScore: payload['similarityScore'] as double?,
              transcribedText: payload['transcribedText'] as String?,
            );
          case 'endSession':
            await _api.endSession(payload['sessionId'] as String);
        }

        // Remover após sucesso
        await (_db.delete(_db.pendingSyncTable)
              ..where((t) => t.id.equals(item.id)))
            .go();
      } catch (e) {
        // Incrementar retry count — desistir após 5 tentativas
        if (item.retryCount >= 5) {
          await (_db.delete(_db.pendingSyncTable)
                ..where((t) => t.id.equals(item.id)))
              .go();
        } else {
          await (_db.update(_db.pendingSyncTable)
                ..where((t) => t.id.equals(item.id)))
              .write(PendingSyncTableCompanion(
                retryCount: Value(item.retryCount + 1)));
        }
      }
    }
  }

  // Sincronizar decks e cards do servidor para local
  Future<void> pullDecksAndCards() async {
    try {
      final result = await _api.getDecks(pageSize: 200);
      final items  = (result['items'] as List<dynamic>);

      for (final d in items) {
        await upsertDeckFromJson(d);
      }
    } catch (_) {
      // Silencioso — dados locais continuam disponíveis
    }
  }

  Future<void> pullCardsForDeck(String deckId) async {
    try {
      final data = await _api.getCards(deckId, pageSize: 500);
      final items = (data['items'] as List? ?? []);

      await _db.cardDao.upsertAll(items.map((c) => cardFromJson(c)).toList());
    } catch (e) {
      // Log ou ignore
    }
  }

  Future<void> upsertDeckFromJson(Map<String, dynamic> d) async {
    await _db.deckDao.upsertDeck(
      DeckTableCompanion(
        id:              Value(d['id']    as String),
        userId:          Value(d['userId'] as String? ?? ''),
        name:            Value(d['name']  as String),
        description:     Value(d['description'] as String?),
        language:        Value(d['language']     as String),
        nativeLanguage:  Value(d['nativeLanguage'] as String),
        maxNewCardsPerDay: Value(d['maxNewCardsPerDay'] as int? ?? 20),
        maxReviewsPerDay:  Value(d['maxReviewsPerDay']  as int? ?? 100),
        isActive:        const Value(true),
        createdAt:       Value(DateTime.parse(d['createdAt'] as String)),
        updatedAt:       Value(DateTime.now().toUtc()),
        lastSyncAt:      Value(DateTime.now().toUtc()),
      ),
    );
  }

  CardTableCompanion cardFromJson(Map<String, dynamic> c) {
    DateTime? parseDate(dynamic v) => v == null ? null : DateTime.tryParse(v as String);

    return CardTableCompanion(
      id:                   Value(c['id']    as String),
      deckId:               Value(c['deckId'] as String),
      front:                Value(c['front']  as String),
      back:                 Value(c['back']   as String),
      pronunciation:        Value(c['pronunciation'] as String?),
      audioPath:            Value(c['audioPath']     as String?),
      listeningRepetitions: Value(c['listeningRepetitions'] as int? ?? 0),
      listeningEaseFactor:  Value((c['listeningEaseFactor']  as num?)?.toDouble() ?? 2.5),
      listeningInterval:    Value(c['listeningInterval']     as int? ?? 0),
      listeningNextReview:  Value(parseDate(c['listeningNextReview'])),
      speakingRepetitions:  Value(c['speakingRepetitions']  as int? ?? 0),
      speakingEaseFactor:   Value((c['speakingEaseFactor']   as num?)?.toDouble() ?? 2.5),
      speakingInterval:     Value(c['speakingInterval']      as int? ?? 0),
      speakingNextReview:   Value(parseDate(c['speakingNextReview'])),
      isActive:             const Value(true),
      updatedAt:            Value(DateTime.now().toUtc()),
    );
  }
}

// Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final db  = ref.read(databaseProvider);
  final api = ref.read(apiClientProvider);
  return SyncService(db, api);
});