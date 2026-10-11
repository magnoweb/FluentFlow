import 'package:fluentflow/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/dto/podcast_dto.dart';
import '../../shared/widgets/ff_loading.dart';
import 'podcast_provider.dart';

enum _PodcastFilter { all, notStarted, inProgress, completed, favorites }

class PodcastLibraryPage extends ConsumerStatefulWidget {
  const PodcastLibraryPage({super.key});

  @override
  ConsumerState<PodcastLibraryPage> createState() => _PodcastLibraryPageState();
}

class _PodcastLibraryPageState extends ConsumerState<PodcastLibraryPage> {
  static const _primary = Color(0xFF594AE2);
  _PodcastFilter _filter = _PodcastFilter.all;

  void _open(PodcastEpisodeDto ep, String start) {
    context.push('/podcasts/${Uri.encodeComponent(ep.id)}?start=$start');
  }

  Future<void> _toggleFavorite(PodcastEpisodeDto ep) async {
    try {
      await ref.read(podcastRepositoryProvider).setFavorite(ep.id, !ep.isFavorite);
      ref.invalidate(podcastLibraryProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _delete(PodcastEpisodeDto ep) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.podcastsDelete),
        content: Text(l10n.podcastsDeleteConfirm(ep.title)),
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
      await ref.read(podcastRepositoryProvider).delete(ep.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.podcastsDeleted)));
      ref.invalidate(podcastLibraryProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  bool _matches(PodcastEpisodeDto ep) => switch (_filter) {
    _PodcastFilter.all => true,
    _PodcastFilter.notStarted => !ep.isCompleted && !ep.isInProgress,
    _PodcastFilter.inProgress => ep.isInProgress,
    _PodcastFilter.completed => ep.isCompleted,
    _PodcastFilter.favorites => ep.isFavorite,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final library = ref.watch(podcastLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.podcastsTitle),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(podcastLibraryProvider.future),
        child: library.when(
          loading: () => const FFLoading(),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 80),
              Center(child: Text('${l10n.commonError}: $e', textAlign: TextAlign.center)),
            ],
          ),
          data: (lib) => _buildContent(context, l10n, lib),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, PodcastLibraryDto lib) {
    final allEpisodes = lib.groups.expand((g) => g.episodes).toList();
    if (allEpisodes.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.podcasts, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Center(child: Text(l10n.podcastsEmpty, style: const TextStyle(color: Colors.grey))),
        ],
      );
    }

    final groups = lib.groups
        .map((g) => (group: g, episodes: g.episodes.where(_matches).toList()))
        .where((x) => x.episodes.isNotEmpty)
        .toList();

    final featured = lib.continueListening ?? lib.upNext;
    final isContinue = lib.continueListening != null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.podcastsSubtitle, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),

        // ── Estatísticas ────────────────────────────────────────────────────
        Row(
          children: [
            _StatBox(
              label: l10n.podcastsStatsCompleted,
              value: '${lib.stats.completedEpisodes}/${lib.stats.totalEpisodes}',
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _StatBox(
              label: l10n.podcastsStatsInProgress,
              value: '${lib.stats.inProgressEpisodes}',
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _StatBox(
              label: l10n.podcastsStatsMinutes,
              value: '${lib.stats.listenedMinutes}',
              color: _primary,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Continuar / A seguir ────────────────────────────────────────────
        if (featured != null) ...[
          _FeaturedCard(
            episode: featured,
            isContinue: isContinue,
            onContinue: () => _open(featured, isContinue ? 'resume' : 'autoplay'),
            onRestart: () => _open(featured, 'restart'),
          ),
          const SizedBox(height: 16),
        ],

        // ── Filtros ─────────────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in _PodcastFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(_filterLabel(l10n, f)),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(l10n.podcastsNoMatches, style: const TextStyle(color: Colors.grey)),
            ),
          )
        else
          for (final x in groups)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: PageStorageKey('podcast-group-${x.group.key}'),
                initiallyExpanded: false,
                shape: const Border(),
                collapsedShape: const Border(),
                leading: const Icon(Icons.podcasts, color: _primary),
                title: Text(
                  _groupTitle(l10n, x.group),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      l10n.podcastsGroupProgress(x.group.completedEpisodes, x.group.totalEpisodes),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: x.group.totalEpisodes == 0
                          ? 0
                          : x.group.completedEpisodes / x.group.totalEpisodes,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.green,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ],
                ),
                children: [
                  for (final ep in x.episodes)
                    _EpisodeTile(
                      episode: ep,
                      onTap: () => _open(ep, ep.isInProgress ? 'resume' : 'autoplay'),
                      onFavorite: () => _toggleFavorite(ep),
                      onDelete: () => _delete(ep),
                    ),
                ],
              ),
            ),
      ],
    );
  }

  String _filterLabel(AppLocalizations l10n, _PodcastFilter f) => switch (f) {
    _PodcastFilter.all => l10n.podcastsFilterAll,
    _PodcastFilter.notStarted => l10n.podcastsFilterNotStarted,
    _PodcastFilter.inProgress => l10n.podcastsFilterInProgress,
    _PodcastFilter.completed => l10n.podcastsFilterCompleted,
    _PodcastFilter.favorites => l10n.podcastsFilterFavorites,
  };

  String _groupTitle(AppLocalizations l10n, PodcastGroupDto g) {
    if (g.series == null || g.series!.isEmpty) return l10n.podcastsGeneral;
    return g.season != null ? '${g.series} · ${l10n.podcastsSeason(g.season!)}' : g.series!;
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}

class _FeaturedCard extends StatelessWidget {
  final PodcastEpisodeDto episode;
  final bool isContinue;
  final VoidCallback onContinue, onRestart;
  const _FeaturedCard({
    required this.episode,
    required this.isContinue,
    required this.onContinue,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primary = Color(0xFF594AE2);
    final pos = episode.progress?.positionMs ?? 0;

    return Card(
      color: primary.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primary.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (isContinue ? l10n.podcastsContinueListening : l10n.podcastsUpNext).toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(episode.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (episode.series != null) ...[
              const SizedBox(height: 2),
              Text(
                [
                  episode.series!,
                  if (episode.episodeNumber != null) '#${episode.episodeNumber}',
                ].join(' · '),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (isContinue) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: episode.progressFraction,
                minHeight: 5,
                borderRadius: BorderRadius.circular(3),
                color: primary,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.podcastsStoppedAt(formatPodcastTime(pos), formatPodcastTime(episode.durationMs)),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(isContinue ? l10n.podcastsContinue : l10n.podcastsListen),
                ),
                if (isContinue) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.replay),
                    label: Text(l10n.podcastsRestart),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final PodcastEpisodeDto episode;
  final VoidCallback onTap, onFavorite, onDelete;
  const _EpisodeTile({
    required this.episode,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ep = episode;

    final Widget statusIcon;
    if (ep.isCompleted) {
      statusIcon = const Icon(Icons.check_circle, color: Colors.green);
    } else if (ep.isInProgress) {
      statusIcon = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          value: ep.progressFraction,
          strokeWidth: 3,
          color: Colors.orange,
          backgroundColor: Colors.grey.shade200,
        ),
      );
    } else {
      statusIcon = const Icon(Icons.radio_button_unchecked, color: Colors.grey);
    }

    final meta = <String>[
      if (ep.episodeNumber != null) '#${ep.episodeNumber}',
      if (ep.level != null && ep.level!.isNotEmpty) ep.level!,
      formatPodcastTime(ep.durationMs),
      if (ep.isCompleted && (ep.progress?.playCount ?? 0) > 1)
        l10n.podcastsTimesListened(ep.progress!.playCount),
    ];

    return ListTile(
      onTap: onTap,
      onLongPress: onDelete, // pressão longa → eliminar
      leading: statusIcon,
      title: Text(
        ep.title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: ep.isCompleted ? Colors.grey.shade700 : null,
        ),
      ),
      subtitle: Text(meta.join(' · '), style: const TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.podcastsFavorite,
            icon: Icon(
              ep.isFavorite ? Icons.star : Icons.star_border,
              color: ep.isFavorite ? Colors.amber : Colors.grey,
            ),
            onPressed: onFavorite,
          ),
          IconButton(
            tooltip: ep.isCompleted
                ? l10n.podcastsListenAgain
                : ep.isInProgress
                    ? l10n.podcastsContinue
                    : l10n.podcastsListen,
            icon: Icon(
              ep.isCompleted ? Icons.replay : Icons.play_circle_fill,
              color: const Color(0xFF594AE2),
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
