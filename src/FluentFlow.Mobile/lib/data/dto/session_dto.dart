import 'dart:ui';
import 'card_dto.dart';

class StudySessionListDto {
  final String  id;
  final String  deckId;
  final String  deckName;
  final String  mode;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int     totalCards;
  final int     reviewedCards;
  final double  averageScore;
  final Duration? duration;

  StudySessionListDto.fromJson(Map<String, dynamic> j)
      : id            = j['id'] as String,
        deckId        = j['deckId'] as String,
        deckName      = j['deckName'] as String,
        mode          = j['mode'] as String,
        startedAt     = DateTime.parse(j['startedAt'] as String),
        endedAt       = j['endedAt'] != null ? DateTime.parse(j['endedAt'] as String) : null,
        totalCards    = j['totalCards'] as int,
        reviewedCards = j['reviewedCards'] as int,
        averageScore  = (j['averageScore'] as num).toDouble(),
        duration      = j['duration'] != null ? _parseDuration(j['duration'] as String) : null;

  static Duration _parseDuration(String s) {
    // formato ISO 8601: "00:05:30" ou "PT5M30S"
    final parts = s.split(':');
    if (parts.length == 3) {
      return Duration(
        hours:   int.tryParse(parts[0]) ?? 0,
        minutes: int.tryParse(parts[1]) ?? 0,
        seconds: int.tryParse(parts[2].split('.').first) ?? 0,
      );
    }
    return Duration.zero;
  }

  String get modeLabel => mode == 'Listening' ? '🎧 Listening' : '🗣️ Speaking';

  String get scoreLabel => averageScore.toStringAsFixed(1);

  String get durationLabel {
    if (duration == null) return '—';
    final m = duration!.inMinutes;
    final s = duration!.inSeconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }
}

class StudySessionDetailDto {
  final String   id;
  final String   deckId;
  final String   deckName;
  final String   mode;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int      totalCards;
  final int      reviewedCards;
  final double   averageScore;
  final Duration? duration;
  final List<StudyReviewDto> reviews;

  StudySessionDetailDto.fromJson(Map<String, dynamic> j)
      : id            = j['id']           as String,
        deckId        = j['deckId']        as String,
        deckName      = j['deckName']      as String,
        mode          = j['mode']          as String,
        startedAt     = DateTime.parse(j['startedAt'] as String),
        endedAt       = j['endedAt'] != null ? DateTime.parse(j['endedAt'] as String) : null,
        totalCards    = j['totalCards']    as int,
        reviewedCards = j['reviewedCards'] as int,
        averageScore  = (j['averageScore'] as num).toDouble(),
        duration      = j['duration'] != null
            ? StudySessionListDto._parseDuration(j['duration'] as String)
            : null,
        reviews = (j['reviews'] as List? ?? [])
            .map((e) => StudyReviewDto.fromJson(e as Map<String, dynamic>))
            .toList();
}

class StudyReviewDto {
  final String   cardId;
  final String   cardFront;
  final String   cardBack;
  final String?  cefrLevel;
  final int      score;
  final double?  similarityScore;
  final String?  transcribedText;
  final int      previousInterval;
  final int      newInterval;
  final DateTime reviewedAt;

  StudyReviewDto.fromJson(Map<String, dynamic> j)
      : cardId           = j['cardId']           as String,
        cardFront        = j['cardFront']         as String,
        cardBack         = j['cardBack']          as String,
        cefrLevel        = j['cefrLevel']         as String?,
        score            = j['score']             as int,
        similarityScore  = (j['similarityScore']  as num?)?.toDouble(),
        transcribedText  = j['transcribedText']   as String?,
        previousInterval = j['previousInterval']  as int,
        newInterval      = j['newInterval']        as int,
        reviewedAt       = DateTime.parse(j['reviewedAt'] as String);

  String get scoreLabel => switch (score) {
    0 => 'Nada',
    1 => 'Errei',
    2 => 'Difícil',
    3 => 'Ok',
    4 => 'Bem',
    5 => 'Fácil',
    _ => '$score'
  };

  Color get scoreColor => switch (score) {
    0 || 1 => const Color(0xFFF44336),
    2 || 3 => const Color(0xFFFF9800),
    _      => const Color(0xFF4CAF50),
  };
}