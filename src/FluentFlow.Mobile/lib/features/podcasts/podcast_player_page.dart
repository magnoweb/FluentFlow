import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluentflow/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/audio_prefs.dart';
import '../../data/dto/podcast_dto.dart';
import '../../shared/widgets/ff_loading.dart';
import 'podcast_provider.dart';

/// Player de um episódio. [start]: 'resume' | 'restart' | 'autoplay' | null.
/// - null → se houver progresso, pergunta se quer continuar ou recomeçar.
class PodcastPlayerPage extends ConsumerStatefulWidget {
  final String episodeId;
  final String? start;
  const PodcastPlayerPage({super.key, required this.episodeId, this.start});

  @override
  ConsumerState<PodcastPlayerPage> createState() => _PodcastPlayerPageState();
}

class _PodcastPlayerPageState extends ConsumerState<PodcastPlayerPage> {
  static const _primary = Color(0xFF594AE2);
  static const _saveInterval = Duration(seconds: 15);
  static const _autoNextSeconds = 5;
  static const _seekStepMs = 5000;

  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription> _subs = [];
  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};

  late final PodcastRepository _repo;
  ProviderContainer? _container;

  PodcastEpisodeDetailDto? _detail;
  PodcastProgressDto? _progress;
  PodcastPrefs _prefs = PodcastPrefs();
  Object? _loadError;
  bool _audioError = false;

  bool _loading = true;
  bool _playing = false;
  bool _sourceReady = false;
  bool _showResumePrompt = false;
  bool _finished = false;
  bool _repeatLine = false;
  bool _dragging = false;

  int _posMs = 0; // tempo "normal" (independente da versão lenta)
  double _dragValue = 0;
  int _activeIndex = -1;
  int _repeatIndex = -1;
  int _lastSavedMs = -1;
  bool _repeatSeeking = false;

  Timer? _saveTimer;
  Timer? _autoNextTimer;
  int _autoNextLeft = 0;

  PodcastEpisodeDto? get _episode => _detail?.episode;

  /// Factor de tempo da versão lenta: ms no ficheiro lento = ms normais / factor.
  double get _factor {
    final ep = _episode;
    if (ep == null || !_prefs.useSlow || ep.slowAudioPath == null) return 1.0;
    final t = ep.slowTempo ?? 0.85;
    return t <= 0 ? 1.0 : t;
  }

  int get _durationMs => _episode?.durationMs ?? 0;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(podcastRepositoryProvider);

    _subs.add(_player.onPositionChanged.listen(_onPosition));
    _subs.add(_player.onPlayerComplete.listen((_) => _onComplete()));
    _subs.add(_player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      final playing = s == PlayerState.playing;
      if (playing != _playing) setState(() => _playing = playing);
    }));

    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container ??= ProviderScope.containerOf(context, listen: false);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _autoNextTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    // Guarda a posição final (fire-and-forget) e actualiza a biblioteca.
    if (_detail != null && !_finished && _sourceReady && _posMs > 0) {
      _repo.updateProgress(widget.episodeId, _posMs).catchError((_) => const PodcastProgressDto());
    }
    final container = _container;
    if (container != null) {
      Future.microtask(() => container.invalidate(podcastLibraryProvider));
    }
    _player.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── Carregamento ─────────────────────────────────────────────────────────────
  Future<void> _load() async {
    try {
      final prefs = await PodcastPrefs.load();
      final detail = await _repo.getEpisode(widget.episodeId);
      if (!mounted) return;

      _prefs = prefs;
      if (!AudioPrefs.speedOptions.contains(_prefs.rate)) _prefs.rate = 1.0;
      _detail = detail;
      _progress = detail.episode.progress;
      for (final l in detail.lines) {
        _lineKeys[l.index] = GlobalKey();
      }

      final saved = _progress?.positionMs ?? 0;
      final completed = _progress?.isCompleted ?? false;
      final hasResume = !completed && saved > 0;

      int startAt = 0;
      bool autoplay = false;
      switch (widget.start) {
        case 'resume':
          startAt = hasResume ? saved : 0;
          autoplay = true;
        case 'restart':
          startAt = 0;
          autoplay = true;
        case 'autoplay':
          startAt = hasResume ? saved : 0;
          autoplay = true;
        default:
          startAt = hasResume ? saved : 0;
          _showResumePrompt = hasResume;
      }

      setState(() {
        _loading = false;
        _posMs = startAt;
        _activeIndex = _lineIndexAt(startAt);
      });

      await _setSource(startAt);
      if (autoplay) await _play();
      _scrollToActive(animate: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e;
      });
    }
  }

  Future<void> _setSource(int normalMs) async {
    final ep = _episode;
    if (ep == null) return;
    final path = _prefs.useSlow && ep.slowAudioPath != null ? ep.slowAudioPath! : ep.audioPath;
    try {
      _sourceReady = false;
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setSource(UrlSource(_repo.audioUrl(path)));
      if (normalMs > 0) await _player.seek(_toAudio(normalMs));
      _sourceReady = true;
      if (_audioError && mounted) setState(() => _audioError = false);
    } catch (_) {
      if (mounted) setState(() => _audioError = true);
    }
  }

  Duration _toAudio(int normalMs) => Duration(milliseconds: (normalMs / _factor).round());
  int _toNormal(Duration audio) => (audio.inMilliseconds * _factor).round();

  // ── Reprodução ───────────────────────────────────────────────────────────────
  Future<void> _play() async {
    if (!_sourceReady) {
      await _setSource(_posMs);
      if (!_sourceReady) return;
    }
    _autoNextTimer?.cancel();
    setState(() {
      _showResumePrompt = false;
      _finished = false;
      _autoNextLeft = 0;
    });
    try {
      await _player.resume();
      // No Android a velocidade só é aplicada depois de iniciar a reprodução.
      await _player.setPlaybackRate(_prefs.rate);
    } catch (_) {
      if (mounted) setState(() => _audioError = true);
      return;
    }
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(_saveInterval, (_) => _saveProgress());
  }

  Future<void> _pause() async {
    await _player.pause();
    _saveTimer?.cancel();
    await _saveProgress();
  }

  Future<void> _togglePlay() => _playing ? _pause() : _play();

  Future<void> _seekTo(int normalMs) async {
    final target = normalMs.clamp(0, _durationMs > 0 ? _durationMs : normalMs).toInt();
    setState(() {
      _posMs = target;
      _activeIndex = _lineIndexAt(target);
      _finished = false;
    });
    if (!_sourceReady) await _setSource(target);
    if (_sourceReady) await _player.seek(_toAudio(target));
    _scrollToActive();
  }

  Future<void> _seekToLine(PodcastLineDto line) async {
    if (_repeatLine) _repeatIndex = line.index;
    await _seekTo(line.startMs);
    if (!_playing) await _play();
  }

  void _stepLine(int delta) {
    final lines = _detail?.lines ?? const <PodcastLineDto>[];
    if (lines.isEmpty) return;
    var i = lines.indexWhere((l) => l.index == _activeIndex);
    if (i < 0) i = delta > 0 ? -1 : 0;
    final next = (i + delta).clamp(0, lines.length - 1).toInt();
    _seekToLine(lines[next]);
  }

  void _onPosition(Duration audioPos) {
    if (!mounted || _detail == null) return;
    final normal = _toNormal(audioPos);

    // Repetir a frase: ao passar o fim da frase, volta ao início.
    if (_repeatLine && _repeatIndex >= 0) {
      final line = _lineByIndex(_repeatIndex);
      if (line != null) {
        if (normal >= line.endMs) {
          if (!_repeatSeeking) {
            _repeatSeeking = true;
            _player.seek(_toAudio(line.startMs));
          }
          return;
        }
        if (normal < line.endMs - 200) _repeatSeeking = false;
      }
    }

    final idx = _lineIndexAt(normal);
    final changed = idx != _activeIndex;
    setState(() {
      _posMs = normal;
      _activeIndex = idx;
    });
    if (changed) _scrollToActive();
  }

  Future<void> _onComplete() async {
    if (!mounted) return;
    _saveTimer?.cancel();
    setState(() {
      _playing = false;
      _finished = true;
      _posMs = _durationMs;
      _repeatLine = false;
      _repeatIndex = -1;
    });
    try {
      final p = await _repo.updateProgress(widget.episodeId, _durationMs, completed: true);
      if (mounted) setState(() => _progress = p);
    } catch (_) {}
    _lastSavedMs = _durationMs;
    // O ficheiro terminou; ao reproduzir de novo recomeça do início.
    _sourceReady = false;

    if (_prefs.autoNext && _detail?.nextEpisodeId != null) _startAutoNext();
  }

  Future<void> _saveProgress() async {
    if (_detail == null || _finished || _posMs <= 0) return;
    if ((_posMs - _lastSavedMs).abs() < 1000) return;
    _lastSavedMs = _posMs;
    try {
      final p = await _repo.updateProgress(widget.episodeId, _posMs);
      if (mounted) setState(() => _progress = p);
    } catch (_) {}
  }

  // ── Próximo episódio automático ─────────────────────────────────────────────
  void _startAutoNext() {
    _autoNextTimer?.cancel();
    setState(() => _autoNextLeft = _autoNextSeconds);
    _autoNextTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_autoNextLeft <= 1) {
        t.cancel();
        _goToEpisode(_detail?.nextEpisodeId, autoplay: true);
      } else {
        setState(() => _autoNextLeft--);
      }
    });
  }

  void _cancelAutoNext() {
    _autoNextTimer?.cancel();
    setState(() => _autoNextLeft = 0);
  }

  void _goToEpisode(String? id, {bool autoplay = false}) {
    if (id == null || !mounted) return;
    _autoNextTimer?.cancel();
    final start = autoplay ? 'autoplay' : '';
    context.pushReplacement(
      '/podcasts/${Uri.encodeComponent(id)}${start.isEmpty ? '' : '?start=$start'}',
    );
  }

  // ── Definições ───────────────────────────────────────────────────────────────
  Future<void> _setRate(double rate) async {
    setState(() => _prefs.rate = rate);
    await _prefs.save();
    if (_playing) await _player.setPlaybackRate(rate);
  }

  Future<void> _setSlow(bool value) async {
    if (_prefs.useSlow == value) return;
    final wasPlaying = _playing;
    final pos = _posMs;
    if (wasPlaying) await _player.pause();
    setState(() => _prefs.useSlow = value);
    await _prefs.save();
    await _setSource(pos);
    if (wasPlaying) await _play();
  }

  void _setRepeatLine(bool value) {
    setState(() {
      _repeatLine = value;
      _repeatIndex = value ? (_activeIndex >= 0 ? _activeIndex : _firstLineIndex()) : -1;
    });
  }

  Future<void> _setPref(void Function() change) async {
    setState(change);
    await _prefs.save();
  }

  // ── Acções do episódio ──────────────────────────────────────────────────────
  Future<void> _toggleFavorite() async {
    final fav = !(_progress?.isFavorite ?? false);
    try {
      final p = await _repo.setFavorite(widget.episodeId, fav);
      if (mounted) setState(() => _progress = p);
    } catch (e) {
      _snack('$e');
    }
  }

  Future<void> _deleteEpisode() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.podcastsDelete),
        content: Text(l10n.podcastsDeleteConfirm(_episode?.title ?? '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await _player.stop();
      await _repo.delete(widget.episodeId);
      // O episódio já não existe: não gravar progresso ao sair.
      _saveTimer?.cancel();
      _autoNextTimer?.cancel();
      _finished = true;
      if (!mounted) return;
      _snack(l10n.podcastsDeleted);
      context.pop();
    } catch (e) {
      _snack('$e');
    }
  }

  Future<void> _markListened(bool listened) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final p = listened
          ? await _repo.updateProgress(widget.episodeId, _durationMs, completed: true)
          : await _repo.resetProgress(widget.episodeId);
      if (!mounted) return;
      setState(() => _progress = p);
      _lastSavedMs = -1;
      _snack(listened ? l10n.podcastsMarkedListened : l10n.podcastsMarkedUnlistened);
    } catch (e) {
      _snack('$e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Transcrição ─────────────────────────────────────────────────────────────
  int _lineIndexAt(int normalMs) {
    final lines = _detail?.lines ?? const <PodcastLineDto>[];
    var idx = -1;
    for (final l in lines) {
      if (l.startMs <= normalMs) {
        idx = l.index;
      } else {
        break;
      }
    }
    return idx;
  }

  int _firstLineIndex() {
    final lines = _detail?.lines ?? const <PodcastLineDto>[];
    return lines.isEmpty ? -1 : lines.first.index;
  }

  PodcastLineDto? _lineByIndex(int index) {
    for (final l in _detail?.lines ?? const <PodcastLineDto>[]) {
      if (l.index == index) return l;
    }
    return null;
  }

  void _scrollToActive({bool animate = true}) {
    if (!_prefs.follow || _activeIndex < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _lineKeys[_activeIndex]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.3,
        duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
        curve: Curves.easeOut,
      );
    });
  }

  String _sectionLabel(AppLocalizations l10n, String? section) => switch (section?.toLowerCase()) {
    'intro' => l10n.podcastsSectionIntro,
    'dialogue' => l10n.podcastsSectionDialogue,
    'review' => l10n.podcastsSectionReview,
    'outro' => l10n.podcastsSectionOutro,
    _ => section ?? '',
  };

  // ── UI ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ep = _episode;
    final isFav = _progress?.isFavorite ?? false;
    final isCompleted = _progress?.isCompleted ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text(ep?.title ?? l10n.podcastsTitle, overflow: TextOverflow.ellipsis),
        actions: [
          if (ep != null) ...[
            IconButton(
              tooltip: l10n.podcastsFavorite,
              icon: Icon(isFav ? Icons.star : Icons.star_border),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              tooltip: l10n.podcastsSettings,
              icon: const Icon(Icons.tune),
              onPressed: () => _showSettings(context),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                switch (v) {
                  case 'listened':
                    _markListened(true);
                  case 'unlistened':
                    _markListened(false);
                  case 'prev':
                    _goToEpisode(_detail?.previousEpisodeId);
                  case 'next':
                    _goToEpisode(_detail?.nextEpisodeId);
                  case 'delete':
                    _deleteEpisode();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: isCompleted ? 'unlistened' : 'listened',
                  child: ListTile(
                    leading: Icon(isCompleted ? Icons.remove_done : Icons.done_all),
                    title: Text(isCompleted ? l10n.podcastsMarkUnlistened : l10n.podcastsMarkListened),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                if (_detail?.previousEpisodeId != null)
                  PopupMenuItem(
                    value: 'prev',
                    child: ListTile(
                      leading: const Icon(Icons.skip_previous),
                      title: Text(l10n.podcastsPreviousEpisode),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                if (_detail?.nextEpisodeId != null)
                  PopupMenuItem(
                    value: 'next',
                    child: ListTile(
                      leading: const Icon(Icons.skip_next),
                      title: Text(l10n.podcastsNextEpisode),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: Text(l10n.podcastsDelete, style: const TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _loading
          ? const FFLoading()
          : _loadError != null || ep == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('${l10n.commonError}: $_loadError', textAlign: TextAlign.center),
                  ),
                )
              : Column(
                  children: [
                    if (_showResumePrompt) _buildResumeBanner(l10n),
                    if (_finished) _buildFinishedBanner(l10n),
                    if (_audioError)
                      MaterialBanner(
                        content: Text(l10n.podcastsAudioError),
                        leading: const Icon(Icons.error_outline, color: Colors.red),
                        actions: [
                          TextButton(
                            onPressed: () => _setSource(_posMs),
                            child: Text(l10n.commonRetry),
                          ),
                        ],
                      ),
                    Expanded(child: _buildTranscript(l10n)),
                    _buildControls(l10n),
                  ],
                ),
    );
  }

  Widget _buildResumeBanner(AppLocalizations l10n) => MaterialBanner(
    leading: const Icon(Icons.history, color: _primary),
    content: Text(l10n.podcastsResumePrompt(formatPodcastTime(_progress?.positionMs ?? 0))),
    actions: [
      TextButton(
        onPressed: () async {
          await _seekTo(0);
          await _play();
        },
        child: Text(l10n.podcastsRestart),
      ),
      FilledButton(onPressed: _play, child: Text(l10n.podcastsContinue)),
    ],
  );

  Widget _buildFinishedBanner(AppLocalizations l10n) {
    final nextTitle = _detail?.nextEpisodeTitle;
    final hasNext = _detail?.nextEpisodeId != null;
    return MaterialBanner(
      backgroundColor: Colors.green.shade50,
      leading: const Icon(Icons.check_circle, color: Colors.green),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.podcastsEpisodeFinished, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (hasNext && _autoNextLeft > 0)
            Text(l10n.podcastsNextIn(nextTitle ?? '', _autoNextLeft), style: const TextStyle(fontSize: 12)),
        ],
      ),
      actions: [
        if (_autoNextLeft > 0)
          TextButton(onPressed: _cancelAutoNext, child: Text(l10n.commonCancel)),
        TextButton(
          onPressed: () async {
            await _seekTo(0);
            await _play();
          },
          child: Text(l10n.podcastsListenAgain),
        ),
        if (hasNext)
          FilledButton(
            onPressed: () => _goToEpisode(_detail?.nextEpisodeId, autoplay: true),
            child: Text(_autoNextLeft > 0 ? l10n.podcastsPlayNow : l10n.podcastsNextEpisode),
          ),
      ],
    );
  }

  Widget _buildTranscript(AppLocalizations l10n) {
    final lines = _detail?.lines ?? const <PodcastLineDto>[];
    final children = <Widget>[];
    String? lastSection;

    for (final line in lines) {
      if (line.section != null && line.section != lastSection) {
        lastSection = line.section;
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
          child: Text(
            _sectionLabel(l10n, line.section).toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
        ));
      }
      children.add(_buildLine(line));
    }

    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _buildLine(PodcastLineDto line) {
    final active = line.index == _activeIndex;
    final repeating = _repeatLine && line.index == _repeatIndex;
    final past = !active && _activeIndex >= 0 && line.index < _activeIndex;

    return Container(
      key: _lineKeys[line.index],
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: active ? _primary.withOpacity(0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: repeating ? Colors.orange : (active ? _primary : Colors.transparent),
            width: 3,
          ),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _seekToLine(line),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (line.speaker.isNotEmpty)
                Text(
                  line.speaker,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? _primary : Colors.grey.shade600,
                  ),
                ),
              Text(
                line.text,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: past ? Colors.grey.shade600 : null,
                ),
              ),
              if (_prefs.showTranslation && (line.translation?.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    line.translation!,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(AppLocalizations l10n) {
    final dur = _durationMs > 0 ? _durationMs : 1;
    final sliderValue = _dragging ? _dragValue : _posMs.clamp(0, dur).toDouble();

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: sliderValue,
                min: 0,
                max: dur.toDouble(),
                onChangeStart: (v) => setState(() {
                  _dragging = true;
                  _dragValue = v;
                }),
                onChanged: (v) => setState(() => _dragValue = v),
                onChangeEnd: (v) async {
                  setState(() => _dragging = false);
                  await _seekTo(v.round());
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(formatPodcastTime(sliderValue.round()), style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    if (_repeatLine)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.repeat_one, size: 16, color: Colors.orange),
                      ),
                    if (_prefs.useSlow && _episode?.slowAudioPath != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.slow_motion_video, size: 16, color: Colors.grey.shade600),
                      ),
                    Text(
                      AudioPrefs.formatRate(_prefs.rate),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 8),
                    Text(formatPodcastTime(_durationMs), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: l10n.podcastsPreviousLine,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () => _stepLine(-1),
                  ),
                  IconButton(
                    tooltip: '-5 s',
                    icon: const Icon(Icons.replay_5),
                    onPressed: () => _seekTo(_posMs - _seekStepMs),
                  ),
                  IconButton.filled(
                    iconSize: 36,
                    style: IconButton.styleFrom(backgroundColor: _primary),
                    icon: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    onPressed: _togglePlay,
                  ),
                  IconButton(
                    tooltip: '+5 s',
                    icon: const Icon(Icons.forward_5),
                    onPressed: () => _seekTo(_posMs + _seekStepMs),
                  ),
                  IconButton(
                    tooltip: l10n.podcastsNextLine,
                    icon: const Icon(Icons.skip_next),
                    onPressed: () => _stepLine(1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ep = _episode;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          // Actualiza a página e a folha ao mesmo tempo.
          Future<void> apply(Future<void> Function() action) async {
            await action();
            setSheet(() {});
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.podcastsSpeed, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final r in AudioPrefs.speedOptions)
                        ChoiceChip(
                          label: Text(AudioPrefs.formatRate(r)),
                          selected: _prefs.rate == r,
                          onSelected: (_) => apply(() => _setRate(r)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (ep?.slowAudioPath != null)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.podcastsSlowVersion(AudioPrefs.formatRate(ep!.slowTempo ?? 0.85))),
                      value: _prefs.useSlow,
                      onChanged: (v) => apply(() => _setSlow(v)),
                    ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.podcastsRepeatLine),
                    value: _repeatLine,
                    onChanged: (v) => apply(() async => _setRepeatLine(v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.podcastsShowTranslation),
                    value: _prefs.showTranslation,
                    onChanged: (v) => apply(() => _setPref(() => _prefs.showTranslation = v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.podcastsFollowText),
                    value: _prefs.follow,
                    onChanged: (v) => apply(() async {
                      await _setPref(() => _prefs.follow = v);
                      if (v) _scrollToActive();
                    }),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.podcastsAutoNext),
                    value: _prefs.autoNext,
                    onChanged: (v) => apply(() => _setPref(() => _prefs.autoNext = v)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
