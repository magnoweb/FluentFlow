import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/dto/podcast_dto.dart';
import '../../data/remote/api_client.dart';
import '../auth/auth_provider.dart';

class PodcastRepository {
  final ApiClient _api;
  PodcastRepository(this._api);

  /// A API devolve 404 com {"error": "..."} (o Dio aceita 404 sem excepção).
  Map<String, dynamic> _ensureOk(Map<String, dynamic> data) {
    if (data.containsKey('error') && data.length == 1) {
      throw Exception(data['error']?.toString() ?? 'Not found');
    }
    return data;
  }

  Future<PodcastLibraryDto> getLibrary() async =>
      PodcastLibraryDto.fromJson(_ensureOk(await _api.getPodcastLibrary()));

  Future<PodcastEpisodeDetailDto> getEpisode(String id) async =>
      PodcastEpisodeDetailDto.fromJson(_ensureOk(await _api.getPodcastEpisode(id)));

  Future<PodcastProgressDto> updateProgress(String id, int positionMs, {bool completed = false}) async =>
      PodcastProgressDto.fromJson(
        _ensureOk(await _api.updatePodcastProgress(id, positionMs: positionMs, completed: completed)),
      );

  Future<PodcastProgressDto> resetProgress(String id) async =>
      PodcastProgressDto.fromJson(_ensureOk(await _api.resetPodcastProgress(id)));

  Future<PodcastProgressDto> setFavorite(String id, bool value) async =>
      PodcastProgressDto.fromJson(_ensureOk(await _api.setPodcastFavorite(id, value)));

  Future<void> delete(String id) => _api.deletePodcast(id);

  String audioUrl(String path) => _api.podcastAudioUrl(path);
}

final podcastRepositoryProvider = Provider<PodcastRepository>(
  (ref) => PodcastRepository(ref.read(apiClientProvider)),
);

final podcastLibraryProvider = FutureProvider.autoDispose<PodcastLibraryDto>(
  (ref) => ref.read(podcastRepositoryProvider).getLibrary(),
);

/// Preferências do player de podcasts (persistidas localmente).
class PodcastPrefs {
  double rate;
  bool useSlow;
  bool autoNext;
  bool showTranslation;
  bool follow;

  PodcastPrefs({
    this.rate = 1.0,
    this.useSlow = false,
    this.autoNext = true,
    this.showTranslation = true,
    this.follow = true,
  });

  static const _prefix = 'ff_podcast_';

  static Future<PodcastPrefs> load() async {
    final p = await SharedPreferences.getInstance();
    return PodcastPrefs(
      rate: p.getDouble('${_prefix}rate') ?? 1.0,
      useSlow: p.getBool('${_prefix}slow') ?? false,
      autoNext: p.getBool('${_prefix}autoNext') ?? true,
      showTranslation: p.getBool('${_prefix}translation') ?? true,
      follow: p.getBool('${_prefix}follow') ?? true,
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('${_prefix}rate', rate);
    await p.setBool('${_prefix}slow', useSlow);
    await p.setBool('${_prefix}autoNext', autoNext);
    await p.setBool('${_prefix}translation', showTranslation);
    await p.setBool('${_prefix}follow', follow);
  }
}

String formatPodcastTime(int ms) {
  final d = Duration(milliseconds: ms < 0 ? 0 : ms);
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}
