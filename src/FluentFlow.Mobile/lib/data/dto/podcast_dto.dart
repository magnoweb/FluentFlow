/// DTOs dos podcasts — espelham FluentFlow.Core/DTOs/PodcastDto.cs (JSON camelCase).

int _int(dynamic v, [int fallback = 0]) => (v as num?)?.toInt() ?? fallback;
int? _intOrNull(dynamic v) => (v as num?)?.toInt();
DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v as String);

class PodcastProgressDto {
  final int positionMs;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? lastPlayedAt;
  final int playCount;
  final bool isFavorite;

  const PodcastProgressDto({
    this.positionMs = 0,
    this.isCompleted = false,
    this.completedAt,
    this.lastPlayedAt,
    this.playCount = 0,
    this.isFavorite = false,
  });

  PodcastProgressDto.fromJson(Map<String, dynamic> j)
    : positionMs = _int(j['positionMs']),
      isCompleted = j['isCompleted'] as bool? ?? false,
      completedAt = _date(j['completedAt']),
      lastPlayedAt = _date(j['lastPlayedAt']),
      playCount = _int(j['playCount']),
      isFavorite = j['isFavorite'] as bool? ?? false;

  bool get isInProgress => !isCompleted && positionMs > 0;
}

class PodcastEpisodeDto {
  final String id;
  final String title;
  final String? description;
  final String language;
  final String? level;
  final String? series;
  final int? season;
  final int? episodeNumber;
  final int durationMs;
  final String audioPath;
  final String? slowAudioPath;
  final double? slowTempo;
  final PodcastProgressDto? progress;

  const PodcastEpisodeDto({
    required this.id,
    required this.title,
    this.description,
    required this.language,
    this.level,
    this.series,
    this.season,
    this.episodeNumber,
    required this.durationMs,
    required this.audioPath,
    this.slowAudioPath,
    this.slowTempo,
    this.progress,
  });

  PodcastEpisodeDto.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      title = j['title'] as String? ?? '',
      description = j['description'] as String?,
      language = j['language'] as String? ?? 'en-US',
      level = j['level'] as String?,
      series = j['series'] as String?,
      season = _intOrNull(j['season']),
      episodeNumber = _intOrNull(j['episodeNumber']),
      durationMs = _int(j['durationMs']),
      audioPath = j['audioPath'] as String? ?? '',
      slowAudioPath = j['slowAudioPath'] as String?,
      slowTempo = (j['slowTempo'] as num?)?.toDouble(),
      progress = j['progress'] == null
          ? null
          : PodcastProgressDto.fromJson(j['progress'] as Map<String, dynamic>);

  PodcastEpisodeDto copyWithProgress(PodcastProgressDto? p) => PodcastEpisodeDto(
    id: id,
    title: title,
    description: description,
    language: language,
    level: level,
    series: series,
    season: season,
    episodeNumber: episodeNumber,
    durationMs: durationMs,
    audioPath: audioPath,
    slowAudioPath: slowAudioPath,
    slowTempo: slowTempo,
    progress: p,
  );

  bool get isCompleted => progress?.isCompleted == true;
  bool get isInProgress => progress?.isInProgress == true;
  bool get isFavorite => progress?.isFavorite == true;

  double get progressFraction => durationMs <= 0 || progress == null
      ? 0
      : (progress!.positionMs / durationMs).clamp(0.0, 1.0).toDouble();
}

class PodcastGroupDto {
  final String key;
  final String? series;
  final int? season;
  final int totalEpisodes;
  final int completedEpisodes;
  final List<PodcastEpisodeDto> episodes;

  PodcastGroupDto.fromJson(Map<String, dynamic> j)
    : key = j['key'] as String,
      series = j['series'] as String?,
      season = _intOrNull(j['season']),
      totalEpisodes = _int(j['totalEpisodes']),
      completedEpisodes = _int(j['completedEpisodes']),
      episodes = (j['episodes'] as List? ?? [])
          .map((e) => PodcastEpisodeDto.fromJson(e as Map<String, dynamic>))
          .toList();
}

class PodcastStatsDto {
  final int totalEpisodes;
  final int completedEpisodes;
  final int inProgressEpisodes;
  final int listenedMinutes;

  PodcastStatsDto.fromJson(Map<String, dynamic> j)
    : totalEpisodes = _int(j['totalEpisodes']),
      completedEpisodes = _int(j['completedEpisodes']),
      inProgressEpisodes = _int(j['inProgressEpisodes']),
      listenedMinutes = _int(j['listenedMinutes']);
}

class PodcastLibraryDto {
  final List<PodcastGroupDto> groups;
  final PodcastEpisodeDto? continueListening;
  final PodcastEpisodeDto? upNext;
  final PodcastStatsDto stats;

  PodcastLibraryDto.fromJson(Map<String, dynamic> j)
    : groups = (j['groups'] as List? ?? [])
          .map((g) => PodcastGroupDto.fromJson(g as Map<String, dynamic>))
          .toList(),
      continueListening = j['continueListening'] == null
          ? null
          : PodcastEpisodeDto.fromJson(j['continueListening'] as Map<String, dynamic>),
      upNext = j['upNext'] == null
          ? null
          : PodcastEpisodeDto.fromJson(j['upNext'] as Map<String, dynamic>),
      stats = PodcastStatsDto.fromJson(j['stats'] as Map<String, dynamic>? ?? const {});
}

class PodcastLineDto {
  final int index;
  final String? section;
  final String speaker;
  final String text;
  final String? translation;
  final int startMs;
  final int endMs;

  PodcastLineDto.fromJson(Map<String, dynamic> j)
    : index = _int(j['index']),
      section = j['section'] as String?,
      speaker = j['speaker'] as String? ?? '',
      text = j['text'] as String? ?? '',
      translation = j['translation'] as String?,
      startMs = _int(j['startMs']),
      endMs = _int(j['endMs']);
}

class PodcastEpisodeDetailDto {
  final PodcastEpisodeDto episode;
  final List<PodcastLineDto> lines;
  final String? previousEpisodeId;
  final String? nextEpisodeId;
  final String? nextEpisodeTitle;

  PodcastEpisodeDetailDto.fromJson(Map<String, dynamic> j)
    : episode = PodcastEpisodeDto.fromJson(j['episode'] as Map<String, dynamic>),
      lines = (j['lines'] as List? ?? [])
          .map((l) => PodcastLineDto.fromJson(l as Map<String, dynamic>))
          .toList(),
      previousEpisodeId = j['previousEpisodeId'] as String?,
      nextEpisodeId = j['nextEpisodeId'] as String?,
      nextEpisodeTitle = j['nextEpisodeTitle'] as String?;
}
