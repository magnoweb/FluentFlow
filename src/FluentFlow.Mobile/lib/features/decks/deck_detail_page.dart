import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' show Value;
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
  String? _playingId; // ID do card a reproduzir actualmente

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

      // Persistir localmente
      final db = ref.read(databaseProvider);
      await db.cardDao.upsertAll(
        items.map((c) {
          DateTime? parseDate(dynamic v) => v == null ? null : DateTime.tryParse(v as String);
          return CardTableCompanion(
            id: Value(c['id'] as String),
            deckId: Value(c['deckId'] as String),
            front: Value(c['front'] as String),
            back: Value(c['back'] as String),
            pronunciation: Value(c['pronunciation'] as String?),
            audioPath: Value(c['audioPath'] as String?),
            listeningRepetitions: Value(c['listeningRepetitions'] as int? ?? 0),
            listeningEaseFactor: Value((c['listeningEaseFactor'] as num?)?.toDouble() ?? 2.5),
            listeningInterval: Value(c['listeningInterval'] as int? ?? 0),
            listeningNextReview: Value(parseDate(c['listeningNextReview'])),
            speakingRepetitions: Value(c['speakingRepetitions'] as int? ?? 0),
            speakingEaseFactor: Value((c['speakingEaseFactor'] as num?)?.toDouble() ?? 2.5),
            speakingInterval: Value(c['speakingInterval'] as int? ?? 0),
            speakingNextReview: Value(parseDate(c['speakingNextReview'])),
            isActive: const Value(true),
            updatedAt: Value(DateTime.now().toUtc()),
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
      // Já a reproduzir — parar
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao reproduzir áudio: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decks = ref.watch(decksProvider);
    final dashboard = ref.watch(dashboardProvider(widget.deckId));

    return Scaffold(
      appBar: FFAppBar(title: 'Detalhe do Deck', showBack: true),
      body: decks.when(
        loading: () => const FFLoading(),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          final deck = list.where((d) => d.id == widget.deckId).firstOrNull;
          if (deck == null) {
            return const Center(child: Text('Deck não encontrado.'));
          }

          return RefreshIndicator(
            onRefresh: _loadCards,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome e idioma
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

                        // Dashboard stats
                        dashboard.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (dash) => dash == null
                              ? const SizedBox.shrink()
                              : _buildStats(dash),
                        ),

                        const SizedBox(height: 16),

                        // Botão único "Estudar"
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.school),
                            label: const Text('Estudar'),
                            onPressed: () =>
                                context.go('/study/${widget.deckId}/plan'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Cabeçalho da lista de cards
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

                // Lista de cards
                if (_loadingCards)
                  const SliverToBoxAdapter(child: FFLoading())
                else if (_cards.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Sem cards neste deck.',
                          style: TextStyle(color: Colors.grey),
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

  Widget _buildStats(dynamic dash) {
    return Row(
      children: [
        _Stat('Total', '${dash.totalCards}', const Color(0xFF594AE2)),
        const SizedBox(width: 8),
        _Stat('Hoje', '${dash.dueToday}', Colors.orange),
        const SizedBox(width: 8),
        _Stat('Novas', '${dash.newToday}', Colors.blue),
        const SizedBox(width: 8),
        _Stat('Estudadas', '${dash.studiedToday}', Colors.green),
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
            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(front, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                      // ← Badge CEFR ao lado do texto
                      CefrBadge(level: card['cefrLevel'] as String?, label: card['cefrLevelLabel'] as String?),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(back, style: const TextStyle(color: Colors.grey, fontSize: 13)),
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

            // Botão de áudio
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
                tooltip: isPlaying ? 'Parar' : 'Reproduzir',
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
