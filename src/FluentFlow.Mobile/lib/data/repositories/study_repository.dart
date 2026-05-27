import 'dart:convert';
import 'package:drift/drift.dart';

import '../local/database.dart';
import '../remote/api_client.dart';
import '../dto/study_dto.dart';

class StudyRepository {
  final ApiClient _api;
  final AppDatabase _db;

  StudyRepository(this._api, this._db);

  Future<StudyPlanDto?> getPlan(String deckId, String mode) async {
    try {
      final data = await _api.getStudyPlan(deckId, mode);
      return StudyPlanDto.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<String?> startSession(String deckId, String mode) async {
    try {
      final data = await _api.startSession(deckId, mode);
      return data['sessionId'] as String?;
    } catch (_) {
      // Offline — gerar ID local temporário
      return 'offline_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> submitReview({
    required String sessionId,
    required String cardId,
    required int score,
    double? similarityScore,
    String? transcribedText,
    required bool isOnline,
  }) async {
    // SM-2 local sempre
    // (modo já passado pelo CardDao.applySM2 antes de chamar aqui)

    if (isOnline && !sessionId.startsWith('offline_')) {
      try {
        await _api.submitReview(
          sessionId: sessionId,
          cardId: cardId,
          score: score,
          similarityScore: similarityScore,
          transcribedText: transcribedText,
        );
        return;
      } catch (_) {
        /* fallthrough para pending */
      }
    }

    // Guardar para sync posterior
    await _db
        .into(_db.pendingSyncTable)
        .insert(
          PendingSyncTableCompanion(
            operation: Value('submitReview'),
            payload: Value(
              jsonEncode({
                'sessionId': sessionId,
                'cardId': cardId,
                'score': score,
                'similarityScore': similarityScore,
                'transcribedText': transcribedText,
              }),
            ),
            createdAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  Future<Map<String, dynamic>?> endSession(
    String sessionId,
    int reviewed,
  ) async {
    if (sessionId.startsWith('offline_')) {
      return {'reviewedCards': reviewed, 'averageScore': 0.0};
    }
    try {
      return await _api.endSession(sessionId);
    } catch (_) {
      return {'reviewedCards': reviewed, 'averageScore': 0.0};
    }
  }
}
