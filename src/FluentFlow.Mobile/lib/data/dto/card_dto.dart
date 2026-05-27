class CardDto {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? pronunciation;
  final String? audioPath;
  final int listeningRepetitions;
  final int listeningInterval;
  final DateTime? listeningNextReview;
  final int speakingRepetitions;
  final int speakingInterval;
  final DateTime? speakingNextReview;

  CardDto.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      deckId = j['deckId'] as String,
      front = j['front'] as String,
      back = j['back'] as String,
      pronunciation = j['pronunciation'] as String?,
      audioPath = j['audioPath'] as String?,
      listeningRepetitions = j['listeningRepetitions'] as int? ?? 0,
      listeningInterval = j['listeningInterval'] as int? ?? 0,
      listeningNextReview = j['listeningNextReview'] != null
          ? DateTime.parse(j['listeningNextReview'] as String)
          : null,
      speakingRepetitions = j['speakingRepetitions'] as int? ?? 0,
      speakingInterval = j['speakingInterval'] as int? ?? 0,
      speakingNextReview = j['speakingNextReview'] != null
          ? DateTime.parse(j['speakingNextReview'] as String)
          : null;
}
