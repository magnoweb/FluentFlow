import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fluentflow/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../data/local/database.dart';
import '../../data/remote/api_client.dart';
import '../../shared/widgets/cefr_badge.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_loading.dart';
import '../auth/auth_provider.dart';
import 'deck_provider.dart';

class DeckDetailPage extends ConsumerStatefulWidget {
  final String deckId;
  const DeckDetailPage({super.key, required this.deckId});

  @override
  ConsumerState<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends ConsumerState<DeckDetailPage> {
  final _player = AudioPlayer();
  String? _playingId;

  List<Map<String, dynamic>> _cards = [];
  bool _loadingCards = true;
  int _totalCards = 0;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _loadingCards = true);
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.getCards(widget.deckId, pageSize: 500);
      final items = (data['items'] as List? ?? []).cast<Map<String, dynamic>>();

      // Persistir localmente — PRESERVAR updatedAt da API
      // Não sobrescrever com DateTime.now() para não corromper o tracking de
      // "estudado hoje" que depende do updatedAt
      final db = ref.read(databaseProvider);
      await db.cardDao.upsertAllPreservingLocal(
        items.map((c) {
          DateTime? parseDate(dynamic v) =>
              v == null ? null : DateTime.tryParse(v as String)?.toUtc();

          // updatedAt vem da API em UTC — usar directamente
          final apiUpdatedAt =
              parseDate(c['updatedAt']) ?? DateTime.now().toUtc();

          return CardTableCompanion(
            id: Value(c['id'] as String),
            deckId: Value(c['deckId'] as String),
            front: Value(c['front'] as String),
            back: Value(c['back'] as String),
            pronunciation: Value(c['pronunciation'] as String?),
            audioPath: Value(c['audioPath'] as String?),
            listeningRepetitions: Value(c['listeningRepetitions'] as int? ?? 0),
            listeningEaseFactor: Value(
              (c['listeningEaseFactor'] as num?)?.toDouble() ?? 2.5,
            ),
            listeningInterval: Value(c['listeningInterval'] as int? ?? 0),
            listeningNextReview: Value(parseDate(c['listeningNextReview'])),
            speakingRepetitions: Value(c['speakingRepetitions'] as int? ?? 0),
            speakingEaseFactor: Value(
              (c['speakingEaseFactor'] as num?)?.toDouble() ?? 2.5,
            ),
            speakingInterval: Value(c['speakingInterval'] as int? ?? 0),
            speakingNextReview: Value(parseDate(c['speakingNextReview'])),
            isActive: const Value(true),
            updatedAt: Value(apiUpdatedAt), // ← da API, não DateTime.now()
          );
        }).toList(),
      );

      setState(() {
        _cards = items;
        _totalCards = data['totalCount'] as int? ?? items.length;
        _loadingCards = false;
      });
    } catch (e) {
      // Fallback local
      final db = ref.read(databaseProvider);
      final local = await db.cardDao.getByDeck(widget.deckId);
      setState(() {
        _cards = local
            .map(
              (c) => {
                'id': c.id,
                'front': c.front,
                'back': c.back,
                'pronunciation': c.pronunciation,
                'audioPath': c.audioPath,
                'cefrLevel': null,
                'cefrLevelLabel': null,
              },
            )
            .toList();
        _totalCards = local.length;
        _loadingCards = false;
      });
    }
  }

  Future<void> _playAudio(String cardId, String audioPath) async {
    if (_playingId == cardId) {
      await _player.stop();
      setState(() => _playingId = null);
      return;
    }
    setState(() => _playingId = cardId);
    try {
      final url = '${ApiConstants.baseUrl}/uploads/$audioPath';
      await _player.play(UrlSource(url));
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playingId = null);
      });
    } catch (e) {
      setState(() => _playingId = null);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonAudioError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final decks = ref.watch(decksProvider);
    final dashboard = ref.watch(dashboardProvider(widget.deckId));

    return Scaffold(
      appBar: FFAppBar(title: l10n.decksDetailTitle, showBack: true),
      body: decks.when(
        loading: () => const FFLoading(),
        error: (e, _) => Center(child: Text('${l10n.commonError}: $e')),
        data: (list) {
          final deck = list.where((d) => d.id == widget.deckId).firstOrNull;
          if (deck == null) {
            return Center(child: Text(l10n.decksNotFound));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadCards();
              // Forçar reload do dashboard da API
              ref.invalidate(dashboardProvider(widget.deckId));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deck.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${deck.language.toUpperCase()} → '
                          '${deck.nativeLanguage.toUpperCase()}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),

                        // Dashboard vem sempre da API
                        dashboard.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (dash) => dash == null
                              ? const SizedBox.shrink()
                              : _buildStats(dash, l10n),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.school),
                            label: Text(l10n.commonStudy),
                            onPressed: () =>
                                context.go('/study/${widget.deckId}/plan'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cards ($_totalCards)',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (_loadingCards)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                if (_loadingCards)
                  const SliverToBoxAdapter(child: FFLoading())
                else if (_cards.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          l10n.decksNoCards,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _CardTile(
                          card: _cards[i],
                          isPlaying: _playingId == _cards[i]['id'],
                          onPlay: _cards[i]['audioPath'] != null
                              ? () => _playAudio(
                                  _cards[i]['id'] as String,
                                  _cards[i]['audioPath'] as String,
                                )
                              : null,
                        ),
                        childCount: _cards.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(dynamic dash, AppLocalizations l10n) {
    return Row(
      children: [
        _Stat(l10n.commonTotal, '${dash.totalCards}', const Color(0xFF594AE2)),
        const SizedBox(width: 8),
        _Stat(l10n.commonToday, '${dash.dueToday}', Colors.orange),
        const SizedBox(width: 8),
        _Stat(l10n.commonNew, '${dash.newToday}', Colors.blue),
        const SizedBox(width: 8),
        _Stat(l10n.commonStudied, '${dash.studiedToday}', Colors.green),
      ],
    );
  }
}

// ── Card tile ─────────────────────────────────────────────────────────────────
class _CardTile extends StatelessWidget {
  final Map<String, dynamic> card;
  final bool isPlaying;
  final VoidCallback? onPlay;

  const _CardTile({required this.card, required this.isPlaying, this.onPlay});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final front = card['front'] as String? ?? '';
    final back = card['back'] as String? ?? '';
    final pronunciation = card['pronunciation'] as String?;
    final hasAudio = card['audioPath'] != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          front,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      CefrBadge(
                        level: card['cefrLevel'] as String?,
                        label: card['cefrLevelLabel'] as String?,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    back,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (pronunciation != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '[$pronunciation]',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (hasAudio)
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isPlaying ? Icons.stop_circle : Icons.play_circle,
                    key: ValueKey(isPlaying),
                    color: isPlaying ? Colors.red : const Color(0xFF594AE2),
                    size: 32,
                  ),
                ),
                onPressed: onPlay,
                tooltip: isPlaying ? l10n.studyStop : l10n.commonPlay,
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

// ── Stat widget ───────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    ),
  );
}
