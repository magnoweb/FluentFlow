import 'card_dto.dart';

class StudyPlanDto {
  final String deckId;
  final String mode;
  final int newCards;
  final int reviewCards;
  final int overdueCards;
  final List<CardDto> cards;

  StudyPlanDto.fromJson(Map<String, dynamic> j)
    : deckId = j['deckId'] as String,
      mode = j['mode'] as String,
      newCards = j['newCards'] as int,
      reviewCards = j['reviewCards'] as int,
      overdueCards = j['overdueCards'] as int,
      cards = (j['cards'] as List)
          .map((e) => CardDto.fromJson(e as Map<String, dynamic>))
          .toList();
}

class DashboardDto {
  final int totalCards;
  final int dueToday;
  final int newToday;
  final int studiedToday;
  final double averageEaseFactor;
  final List<DailyStatDto> last30Days;

  DashboardDto.fromJson(Map<String, dynamic> j)
    : totalCards = j['totalCards'] as int,
      dueToday = j['dueToday'] as int,
      newToday = j['newToday'] as int,
      studiedToday = j['studiedToday'] as int,
      averageEaseFactor = (j['averageEaseFactor'] as num).toDouble(),
      last30Days = (j['last30Days'] as List)
          .map((e) => DailyStatDto.fromJson(e as Map<String, dynamic>))
          .toList();
}

class DailyStatDto {
  final DateTime date;
  final int cardsReviewed;
  final int cardsNew;
  final double averageScore;

  DailyStatDto.fromJson(Map<String, dynamic> j)
    : date = DateTime.parse(j['date'] as String),
      cardsReviewed = j['cardsReviewed'] as int,
      cardsNew = j['cardsNew'] as int,
      averageScore = (j['averageScore'] as num).toDouble();
}

// Importar aqui para evitar dependência circular
