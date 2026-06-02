import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/dto/session_dto.dart';
import '../../data/remote/api_client.dart';
import '../../shared/widgets/cefr_badge.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_loading.dart';
import '../auth/auth_provider.dart';

class SessionListPage extends ConsumerStatefulWidget {
  final String? deckId;
  const SessionListPage({super.key, this.deckId});

  @override
  ConsumerState<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends ConsumerState<SessionListPage> {
  final List<StudySessionListDto> _sessions = [];
  bool _loading = true;
  bool _hasMore = true;
  int _page = 1;
  String? _modeFilter; // null = todos

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _sessions.clear();
      _page = 1;
      _hasMore = true;
    }
    setState(() => _loading = true);

    try {
      final api  = ref.read(apiClientProvider);
      final data = await api.getSessions(deckId: widget.deckId, page: _page, pageSize: 20);

      final items = (data['items'] as List? ?? [])
          .map((e) => StudySessionListDto.fromJson(
          e as Map<String, dynamic>))
          .where((s) => _modeFilter == null || s.mode == _modeFilter)
          .toList();

      setState(() {
        _sessions.addAll(items);
        _hasMore = _page < (data['totalPages'] as int? ?? 1);
        _loading = false;
        _page++;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FFAppBar(title: 'Sessões de Estudo', showBack: true),
      body: SafeArea(
        child: Column(children: [
          // Filtro de modo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _FilterChip(
                label: 'Todas',
                selected: _modeFilter == null,
                onTap: () => setState(() {
                  _modeFilter = null;
                  _load(reset: true);
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '🎧 Listening',
                selected: _modeFilter == 'Listening',
                onTap: () => setState(() {
                  _modeFilter = 'Listening';
                  _load(reset: true);
                }),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label:    '🗣️ Speaking',
                selected: _modeFilter == 'Speaking',
                onTap: () => setState(() {
                  _modeFilter = 'Speaking';
                  _load(reset: true);
                }),
              ),
            ]),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _loading && _sessions.isEmpty
                ? const FFLoading()
                : _sessions.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Nenhuma sessão encontrada.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
              : RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _sessions.length + (_hasMore ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _sessions.length) {
                    _load();
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _SessionCard(
                    session: _sessions[i],
                    onTap: () => context.go('/sessions/${_sessions[i].id}'),
                  );
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final StudySessionListDto session;
  final VoidCallback onTap;
  const _SessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scoreColor = session.averageScore >= 4.0
        ? Colors.green
        : session.averageScore >= 2.5
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deck name + mode badge
              Row(children: [
                Expanded(
                  child: Text(session.deckName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                _ModeBadge(mode: session.mode),
              ]),
              const SizedBox(height: 8),

              // Stats row
              Row(children: [
                _MiniStat(
                  icon: Icons.style,
                  value: '${session.reviewedCards}',
                  label: 'cards',
                ),
                const SizedBox(width: 16),
                _MiniStat(
                  icon: Icons.star,
                  value: session.scoreLabel,
                  label: 'score',
                  color: scoreColor,
                ),
                const SizedBox(width: 16),
                _MiniStat(
                  icon: Icons.timer,
                  value: session.durationLabel,
                  label: 'duração',
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ]),

              const SizedBox(height: 8),

              // Data
              Text(_formatDate(session.startedAt), style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}  '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

// ── Página de detalhe ─────────────────────────────────────────────────────────
class SessionDetailPage extends ConsumerStatefulWidget {
  final String sessionId;
  const SessionDetailPage({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState
    extends ConsumerState<SessionDetailPage> {

  StudySessionDetailDto? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(apiClientProvider).getSessionDetail(widget.sessionId);
      setState(() {
        _session = StudySessionDetailDto.fromJson(data);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FFAppBar(title: 'Detalhe da Sessão', showBack: true),
      body: SafeArea(
        child: _loading
            ? const FFLoading()
            : _session == null
            ? const Center(child: Text('Sessão não encontrada.'))
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final s = _session!;
    final scoreColor = s.averageScore >= 4.0 ? Colors.green
        : s.averageScore >= 2.5 ? Colors.orange
        : Colors.red;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Header ──────────────────────────────────────────────────────
          Text(s.deckName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(children: [
            _ModeBadge(mode: s.mode),
            const SizedBox(width: 8),
            Text(_formatDate(s.startedAt), style: const TextStyle( color: Colors.grey, fontSize: 12)),
          ]),

          const SizedBox(height: 16),

          // ── Stats cards ─────────────────────────────────────────────────
          Row(children: [
            _StatBox(
              label: 'Cards revistos',
              value: '${s.reviewedCards}/${s.totalCards}',
              icon: Icons.style,
              color: const Color(0xFF594AE2),
            ),
            const SizedBox(width: 8),
            _StatBox(
              label: 'Score médio',
              value: s.averageScore.toStringAsFixed(1),
              icon: Icons.star,
              color: scoreColor,
            ),
            const SizedBox(width: 8),
            _StatBox(
              label: 'Duração',
              value: _durationLabel(s.duration),
              icon: Icons.timer,
              color: Colors.blueGrey,
            ),
          ]),

          const SizedBox(height: 20),

          // ── Distribuição de scores ──────────────────────────────────────
          if (s.reviews.isNotEmpty) ...[
            Text('Distribuição de scores',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _ScoreDistribution(reviews: s.reviews),
            const SizedBox(height: 20),
          ],

          // ── Lista de reviews ────────────────────────────────────────────
          Text('Cards revistos (${s.reviews.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ...s.reviews.map((r) => _ReviewTile(review: r)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final l = dt.toLocal();
    return '${l.day.toString().padLeft(2,'0')}/'
        '${l.month.toString().padLeft(2,'0')}/'
        '${l.year}  '
        '${l.hour.toString().padLeft(2,'0')}:'
        '${l.minute.toString().padLeft(2,'0')}';
  }

  String _durationLabel(Duration? d) {
    if (d == null) return '—';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }
}

// ── Review tile ───────────────────────────────────────────────────────────────
class _ReviewTile extends StatelessWidget {
  final StudyReviewDto review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Frente + nível CEFR + score
            Row(children: [
              Expanded(
                child: Text(review.cardFront, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              const SizedBox(width: 6),
              CefrBadge(level: review.cefrLevel),
              const SizedBox(width: 6),
              _ScoreBadge(score: review.score),
            ]),

            const SizedBox(height: 4),

            // Verso
            Text(review.cardBack, style: const TextStyle( color: Colors.grey, fontSize: 13)),

            // Transcrição (Speaking)
            if (review.transcribedText != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.mic, size: 13, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(review.transcribedText!,
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                ),
                if (review.similarityScore != null)
                  Text('${(review.similarityScore! * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: review.similarityScore! >= 0.85
                              ? Colors.green
                              : review.similarityScore! >= 0.60
                              ? Colors.orange
                              : Colors.red)),
              ]),
            ],

            const SizedBox(height: 6),

            // Intervalo SM-2
            Row(children: [
              const Icon(Icons.update, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Intervalo: ${review.previousInterval}d → ${review.newInterval}d',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Score distribution ────────────────────────────────────────────────────────
class _ScoreDistribution extends StatelessWidget {
  final List<StudyReviewDto> reviews;
  const _ScoreDistribution({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final counts = List.filled(6, 0);
    for (final r in reviews) {
      if (r.score >= 0 && r.score <= 5) counts[r.score]++;
    }
    final max = counts.reduce((a, b) => a > b ? a : b);

    final labels = ['0', '1', '2', '3', '4', '5'];
    final colors = [
      Colors.red, Colors.red,
      Colors.orange, Colors.orange,
      Colors.green, Colors.green,
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (i) {
          final ratio = max == 0 ? 0.0 : counts[i] / max;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(children: [
                Text('${counts[i]}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: Math.max(4.0, ratio * 60),
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(labels[i], style: TextStyle( fontSize: 11, fontWeight: FontWeight.bold, color: colors[i])),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────
class _ModeBadge extends StatelessWidget {
  final String mode;
  const _ModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    final isListening = mode == 'Listening';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isListening
            ? const Color(0xFF594AE2).withOpacity(0.1)
            : const Color(0xFF7B6EF5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isListening ? '🎧 Listening' : '🗣️ Speaking',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isListening ? const Color(0xFF594AE2) : const Color(0xFF7B6EF5),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 4 ? Colors.green
        : score >= 2 ? Colors.orange
        : Colors.red;
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Center(
        child: Text('$score', style: TextStyle( fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _MiniStat({required this.icon, required this.value, required this.label, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 3),
    Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    const SizedBox(width: 2),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF594AE2) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.grey.shade700)),
    ),
  );
}