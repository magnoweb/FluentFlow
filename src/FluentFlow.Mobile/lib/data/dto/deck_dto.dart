class DeckDto {
  final String id;
  final String name;
  final String? description;
  final String language;
  final String nativeLanguage;
  final int maxNewCardsPerDay;
  final int maxReviewsPerDay;
  final int totalCards;
  final DateTime createdAt;

  DeckDto.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      description = j['description'] as String?,
      language = j['language'] as String,
      nativeLanguage = j['nativeLanguage'] as String,
      maxNewCardsPerDay = j['maxNewCardsPerDay'] as int? ?? 20,
      maxReviewsPerDay = j['maxReviewsPerDay'] as int? ?? 100,
      totalCards = j['totalCards'] as int? ?? 0,
      createdAt = DateTime.parse(j['createdAt'] as String);
}

class PagedDecksDto {
  final List<DeckDto> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  PagedDecksDto.fromJson(Map<String, dynamic> j)
    : items = (j['items'] as List)
          .map((e) => DeckDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount = j['totalCount'] as int,
      page = j['page'] as int,
      pageSize = j['pageSize'] as int,
      totalPages = j['totalPages'] as int;
}
