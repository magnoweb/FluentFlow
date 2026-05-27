import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' hide Column, Row, Table;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/local/database.dart';
import '../../data/remote/api_client.dart';
import '../../core/utils/text_similarity.dart';
import '../../domain/sync/sync_service.dart';
import '../auth/auth_provider.dart' hide databaseProvider;
import 'study_provider.dart';

class StudySessionPage extends ConsumerStatefulWidget {
  final String sessionId;
  final String deckId;
  final String mode;

  const StudySessionPage({
    super.key,
    required this.sessionId,
    required this.deckId,
    required this.mode,
  });

  @override
  ConsumerState<StudySessionPage> createState() =>
      _StudySessionPageState();
}

class _StudySessionPageState
    extends ConsumerState<StudySessionPage> {

  final _player   = AudioPlayer();
  final _recorder = AudioRecorder();

  List<CardTableData> _cards    = [];
  int     _currentIndex         = 0;
  bool    _flipped              = false;
  bool    _recording            = false;
  bool    _transcribing         = false;
  String? _transcribedText;
  double  _similarityRatio      = 0;
  bool    _submitting           = false;
  bool    _isOnline             = true;
  String? _recordingPath;

  CardTableData? get _current => _currentIndex < _cards.length ? _cards[_currentIndex] : null;

  int get _reviewedCount => _currentIndex;
  double get _progress => _cards.isEmpty ? 0 : _currentIndex / _cards.length;

  @override
  void initState() {
    super.initState();
    _loadCards();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() => _isOnline = result.any((c) => c != ConnectivityResult.none));

    Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((c) => c != ConnectivityResult.none);
      if (!_isOnline && online) {
        // Ligação restaurada — sincronizar
        ref.read(syncServiceProvider).syncPendingOperations();
      }
      setState(() => _isOnline = online);
    });
  }

  Future<void> _loadCards() async {
    final db    = ref.read(databaseProvider);
    final deck  = await (db.select(db.deckTable)
          ..where((t) => t.id.equals(widget.deckId)))
        .getSingleOrNull();

    if (deck == null) { context.go('/decks'); return; }

    final cards = await db.cardDao.getDueCards(
      widget.deckId, widget.mode,
      deck.maxNewCardsPerDay, deck.maxReviewsPerDay,
    );

    setState(() => _cards = cards);

    // Auto-play áudio no primeiro card (Listening)
    if (widget.mode == 'Listening' && _current?.audioPath != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      _playAudio(_current!.audioPath!);
    }
  }

  // ── Áudio ──────────────────────────────────────────────────────────────────
  Future<void> _playAudio(String path) async {
    try {
      final url = '${ref.read(apiClientProvider)}/uploads/$path';
      await _player.play(UrlSource(url));
    } catch (_) {}
  }

  // ── Gravação ───────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir  = await getTemporaryDirectory();
    _recordingPath =
        '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc,
                         sampleRate: 16000, numChannels: 1),
      path: _recordingPath!,
    );
    setState(() => _recording = true);
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() { _recording = false; _transcribing = true; });

    if (path == null) {
      setState(() => _transcribing = false);
      return;
    }

    // Enviar para API ou calcular localmente
    if (_isOnline && _current != null) {
      try {
        final bytes  = await File(path).readAsBytes();
        final b64    = base64Encode(bytes);
        final api    = ref.read(apiClientProvider);
        final result = await api.transcribeAudio(
          audioBase64:  b64,
          originalText: _current!.front,
          language:     'en',
        );
        setState(() {
          _transcribedText = result['transcribedText'] as String?;
          _similarityRatio = (result['similarityRatio'] as num?)
                              ?.toDouble() ?? 0;
          _transcribing    = false;
          _flipped         = true;
        });
      } catch (_) {
        _fallbackSimilarity(path);
      }
    } else {
      _fallbackSimilarity(path);
    }
  }

  // Fallback offline — não há transcrição, score manual
  void _fallbackSimilarity(String path) {
    setState(() {
      _transcribedText = null;
      _similarityRatio = 0;
      _transcribing    = false;
      _flipped         = true;
    });
  }

  // ── Review ─────────────────────────────────────────────────────────────────
  Future<void> _submitReview(int score) async {
    if (_current == null || _submitting) return;
    setState(() => _submitting = true);

    final db     = ref.read(databaseProvider);
    final cardId = _current!.id;

    // Actualizar SM-2 localmente (funciona offline)
    await db.cardDao.applySM2(cardId, widget.mode, score);

    if (_isOnline) {
      try {
        await ref.read(apiClientProvider).submitReview(
          sessionId:       widget.sessionId,
          cardId:          cardId,
          score:           score,
          similarityScore: widget.mode == 'Speaking' ? _similarityRatio : null,
          transcribedText: _transcribedText,
        );
      } catch (_) {
        // Guardar para sync posterior
        await db.into(db.pendingSyncTable).insert(
          PendingSyncTableCompanion(
            operation: Value('submitReview'),
            payload:   Value(jsonEncode({
              'sessionId': widget.sessionId,
              'cardId':    cardId,
              'score':     score,
              'similarityScore': _similarityRatio,
              'transcribedText': _transcribedText,
            })),
            createdAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    } else {
      // Offline — guardar para sincronizar depois
      await db.into(db.pendingSyncTable).insert(
        PendingSyncTableCompanion(
          operation: Value('submitReview'),
          payload:   Value(jsonEncode({
            'sessionId': widget.sessionId,
            'cardId':    cardId,
            'score':     score,
          })),
          createdAt: Value(DateTime.now().toUtc()),
        ),
      );
    }

    setState(() {
      _currentIndex++;
      _flipped         = false;
      _transcribedText = null;
      _similarityRatio = 0;
      _submitting      = false;
    });

    // Auto-play próximo card
    if (_current != null &&
        widget.mode == 'Listening' &&
        _current!.audioPath != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      _playAudio(_current!.audioPath!);
    }

    // Fim da sessão
    if (_currentIndex >= _cards.length) {
      _endSession();
    }
  }

  Future<void> _endSession() async {
    try {
      if (_isOnline) {
        final result =
            await ref.read(apiClientProvider).endSession(widget.sessionId);
        final reviewed = result['reviewedCards'] as int? ?? _reviewedCount;
        final average  = (result['averageScore'] as num?)?.toDouble() ?? 0;
        if (mounted) {
          context.go(
              '/study/summary/${widget.sessionId}'
              '?reviewed=$reviewed&average=$average');
        }
      } else {
        if (mounted) {
          context.go(
              '/study/summary/${widget.sessionId}'
              '?reviewed=$_reviewedCount&average=0');
        }
      }
    } catch (_) {
      if (mounted) context.go('/decks');
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_current == null && _cards.isEmpty) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (_currentIndex >= _cards.length) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == 'Listening'
            ? '🎧 Listening' : '🗣️ Speaking'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.stop, color: Colors.white),
            label: const Text('Terminar',
                style: TextStyle(color: Colors.white)),
            onPressed: () => _confirmEnd(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner offline
          if (!_isOnline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: const Row(children: [
                Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Text('Modo offline — as reviews serão sincronizadas',
                    style: TextStyle(fontSize: 13)),
              ]),
            ),

          // Progress
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$_reviewedCount / ${_cards.length} cards',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text('${(_progress * 100).toInt()}%',
                        style: Theme.of(context)
                            .textTheme.bodySmall
                            ?.copyWith(color: const Color(0xFF594AE2))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:          _progress,
                    minHeight:      8,
                    backgroundColor: const Color(0xFFE8E5FF),
                    valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF594AE2)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                // Card flip
                GestureDetector(
                  onTap: () => setState(() => _flipped = !_flipped),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_flipped),
                      width: double.infinity,
                      constraints:
                          const BoxConstraints(minHeight: 160),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF594AE2)
                                .withOpacity(0.08),
                            blurRadius: 16, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_flipped) ...[
                            Text(_current!.front,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            if (widget.mode == 'Listening' &&
                                _current!.audioPath != null) ...[
                              const SizedBox(height: 16),
                              IconButton.filled(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () =>
                                    _playAudio(_current!.audioPath!),
                                style: IconButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF594AE2)),
                              ),
                            ],
                            const SizedBox(height: 12),
                            const Text('Toca para ver a resposta',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                          ] else ...[
                            Text(_current!.back,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF594AE2)),
                                textAlign: TextAlign.center),
                            if (_current!.pronunciation != null) ...[
                              const SizedBox(height: 8),
                              Text('[${_current!.pronunciation}]',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey)),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Speaking — gravação e resultado
                if (widget.mode == 'Speaking') ...[
                  const SizedBox(height: 16),
                  _buildSpeakingPanel(),
                ],

                // Scores SM-2 — visíveis após flip
                if (_flipped) ...[
                  const SizedBox(height: 16),
                  _buildScoreButtons(),
                ],

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakingPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: [
        const Text('Diz a palavra em voz alta',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),

        if (!_recording && _transcribedText == null && !_transcribing)
          FilledButton.icon(
            icon:  const Icon(Icons.mic),
            label: const Text('Gravar'),
            onPressed: _startRecording,
          )
        else if (_recording)
          Column(children: [
            const SizedBox(
              width: 32, height: 32,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Colors.red)),
            const SizedBox(height: 8),
            const Text('A gravar...',
                style: TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon:  const Icon(Icons.stop, color: Colors.red),
              label: const Text('Parar',
                  style: TextStyle(color: Colors.red)),
              onPressed: _stopRecording,
            ),
          ])
        else if (_transcribing)
          const Column(children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('A transcrever...', style: TextStyle(fontSize: 13)),
          ])
        else if (_transcribedText != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Você disse:',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              _SimilarityChip(ratio: _similarityRatio),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:        Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border:       Border.all(color: Colors.grey.shade200),
            ),
            child: Text(_transcribedText!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:          _similarityRatio,
              minHeight:      6,
              backgroundColor: Colors.grey.shade200,
              valueColor:     AlwaysStoppedAnimation(
                  _similarityRatio >= 0.85 ? Colors.green
                : _similarityRatio >= 0.60 ? Colors.orange
                : Colors.red),
            ),
          ),
          TextButton.icon(
            icon:  const Icon(Icons.refresh, size: 16),
            label: const Text('Tentar novamente'),
            onPressed: () => setState(() {
              _transcribedText = null;
              _similarityRatio = 0;
              _flipped         = false;
            }),
          ),
        ],
      ]),
    );
  }

  Widget _buildScoreButtons() {
    const scores = [
      ('Nada (0)',    0, Colors.red),
      ('Errei (1)',   1, Colors.red),
      ('Difícil (2)', 2, Colors.orange),
      ('Ok (3)',      3, Colors.orange),
      ('Bem (4)',     4, Colors.green),
      ('Fácil (5)',   5, Colors.green),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Como correu?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount:    3,
          shrinkWrap:        true,
          physics:           const NeverScrollableScrollPhysics(),
          crossAxisSpacing:  8,
          mainAxisSpacing:   8,
          childAspectRatio:  2.2,
          children: scores.map((s) {
            return OutlinedButton(
              onPressed: _submitting ? null : () => _submitReview(s.$2),
              style: OutlinedButton.styleFrom(
                foregroundColor: s.$3,
                side: BorderSide(color: s.$3.withOpacity(0.5)),
                padding: EdgeInsets.zero,
              ),
              child: Text(s.$1,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _confirmEnd() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Terminar sessão?'),
        content: Text('$_reviewedCount de ${_cards.length} '
                      'cards revistos serão guardados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Terminar')),
        ],
      ),
    );
    if (confirm == true) _endSession();
  }
}

class _SimilarityChip extends StatelessWidget {
  final double ratio;
  const _SimilarityChip({required this.ratio});

  @override
  Widget build(BuildContext context) {
    final pct   = (ratio * 100).toInt();
    final color = ratio >= 0.85 ? Colors.green
                : ratio >= 0.60 ? Colors.orange
                : Colors.red;
    return Chip(
      label: Text('$pct%',
          style: TextStyle(color: color, fontWeight: FontWeight.bold,
                           fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side:            BorderSide(color: color.withOpacity(0.3)),
      padding:         const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}