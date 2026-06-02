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
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/constants/api_constants.dart';
import '../../data/local/database.dart';
import '../../data/remote/api_client.dart';
import '../../core/utils/text_similarity.dart';
import '../../domain/sync/sync_service.dart';
import '../../shared/widgets/icon_mini_waveform.dart';
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
  ConsumerState<StudySessionPage> createState() => _StudySessionPageState();
}

class _StudySessionPageState extends ConsumerState<StudySessionPage> {
  // ── Áudio / gravação ───────────────────────────────────────────────────────
  final _player = AudioPlayer();
  final _recorder = AudioRecorder();
  final _speechToText = SpeechToText();

  // ── Estado da sessão ───────────────────────────────────────────────────────
  List<CardTableData> _cards = [];
  int _currentIndex = 0;
  bool _flipped = false;
  bool _submitting = false;
  bool _isOnline = true;

  // ── Estado da gravação / transcrição ───────────────────────────────────────
  bool _recording = false;
  bool _transcribing = false;
  String? _transcribedText;
  double _similarityRatio = 0;
  String? _recordingPath;
  bool _isPlaying = false;

  // ── speech_to_text ────────────────────────────────────────────────────────
  String? _speechLocaleId;
  bool _speechAvailable = false;
  bool _speechListening = false;
  String _speechPartialResult = '';

  // ── Helpers ────────────────────────────────────────────────────────────────
  String? _deckLang;
  CardTableData? get _current => _currentIndex < _cards.length ? _cards[_currentIndex] : null;

  int get _reviewedCount => _currentIndex;
  double get _progress => _cards.isEmpty ? 0 : _currentIndex / _cards.length;

  // ── Modo de transcrição activo ─────────────────────────────────────────────
  // online  → API Whisper
  // offline → speech_to_text nativo
  bool get _useNativeSpeech => !_isOnline && _speechAvailable;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkConnectivity();
    await _initSpeechToText();
    await _loadCards();

    // Ouve o evento de finalização
    _player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _recorder.dispose();
    _speechToText.stop();
    super.dispose();
  }

  // ── Conectividade ──────────────────────────────────────────────────────────
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

  // ── Inicializar speech_to_text ─────────────────────────────────────────────
  Future<void> _initSpeechToText() async {
    try {
      final available = await _speechToText.initialize(
        onError:  (e) => debugPrint('STT error: ${e.errorMsg}'),
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') &&
              mounted && _speechListening) {
            _onSpeechDone();
          }
        },
      );

      if (!available) {
        setState(() => _speechAvailable = false);
        return;
      }

      // Verificar qual locale usar para o idioma do deck
      _speechLocaleId = await _resolveBestLocale(_deckLang);

      setState(() => _speechAvailable = _speechLocaleId != null);

      debugPrint('STT locale seleccionado: $_speechLocaleId');
    } catch (e) {
      setState(() => _speechAvailable = false);
    }
  }

  /// Tenta encontrar o melhor locale disponível para o idioma pedido.
  /// Retorna null se nenhum locale compatível estiver disponível.
  Future<String?> _resolveBestLocale(String? languageCode) async {
    try {
      final locales = await _speechToText.locales();
      if (locales.isEmpty || languageCode == null) return null;

      // 1. Exact match — ex: 'en_US'
      final exact = locales.where((l) =>
          l.localeId.toLowerCase().startsWith(
              languageCode.toLowerCase())).toList();

      if (exact.isNotEmpty) {
        // Preferir en_US > en_GB > qualquer outro en_*
        final preferred = exact.firstWhere(
              (l) => l.localeId == 'en_US',
          orElse: () => exact.first,
        );
        return preferred.localeId;
      }

      // 2. Nenhum locale do idioma pedido — retornar null
      // (não forçar locale errado)
      debugPrint('Nenhum locale "$languageCode" disponível. '
              'Locales no dispositivo: ${locales.map((l) => l.localeId).toList()}');
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Carregar cards ─────────────────────────────────────────────────────────
  Future<void> _loadCards() async {
    final db   = ref.read(databaseProvider);
    final sync = ref.read(syncServiceProvider);

    // 1. Sincronizar se estiver online
    if (_isOnline) {
      try {
        await sync.pullCardsForDeck(widget.deckId);
        await sync.pullDecksAndCards();
      } catch (e) {
        debugPrint('Pull cards falhou: $e');
        // Continua com dados locais se existirem
      }
    }

    // 2. Buscar deck local (sempre do DB)
    final deck = await db.deckDao.getById(widget.deckId);

    if (deck == null) {
      if (mounted) context.go('/decks');
      return;
    }

    // 3. Buscar cards do plano de hoje (local — já sincronizado)
    final cards = await db.cardDao.getDueCards(widget.deckId, widget.mode, deck.maxNewCardsPerDay, deck.maxReviewsPerDay);

    if (!mounted) return;

    // 4. Se não há cards para hoje, mostrar mensagem e sair
    if (cards.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title:   const Text('Sem cards para hoje'),
          content: const Text('Não há cards para rever hoje neste deck e modo.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/decks');
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() { _cards = cards; _deckLang = deck.language; });

    // Auto-play áudio no primeiro card (Listening)
    if (widget.mode == 'Listening' && _current?.audioPath != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      _playAudio(_current!.audioPath!);
    }
  }

  // ── Reprodução de áudio ────────────────────────────────────────────────────
  Future<void> _playAudio(String path) async {
    try {
      await _player.play(UrlSource('${ApiConstants.baseUrl}/uploads/$path'));
      setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('Erro ao reproduzir áudio: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GRAVAÇÃO — decisão online/offline
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _startRecording() async {
    if (_useNativeSpeech) {
      await _startNativeSpeech();
    } else {
      await _startWhisperRecording();
    }
  }

  Future<void> _stopRecording() async {
    if (_useNativeSpeech) {
      await _stopNativeSpeech();
    } else {
      await _stopWhisperRecording();
    }
  }

  // ── Opção A — Whisper via API (online) ────────────────────────────────────
  Future<void> _startWhisperRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    _recordingPath =
    '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          numChannels: 1),
      path: _recordingPath!,
    );
    setState(() => _recording = true);
  }

  Future<void> _stopWhisperRecording() async {
    final path = await _recorder.stop();
    setState(() { _recording = false; _transcribing = true; });

    if (path == null || _current == null) {
      setState(() => _transcribing = false);
      return;
    }

    try {
      final bytes = await File(path).readAsBytes();
      final b64 = base64Encode(bytes);
      final result = await ref.read(apiClientProvider).transcribeAudio(
        audioBase64: b64,
        originalText: _current!.front,
        language: 'en',
      );
      _applyTranscriptionResult(result['transcribedText'] as String? ?? '');
    } catch (_) {
      // API falhou — tentar fallback para speech_to_text se disponível
      if (_speechAvailable) {
        setState(() => _transcribing = false);
        await _startNativeSpeech();
      } else {
        _applyFallback();
      }
    }
  }

  // ── Opção B — speech_to_text nativo (offline) ─────────────────────────────
  Future<void> _startNativeSpeech() async {
    if (!_speechAvailable || _speechLocaleId == null) {
      _applyFallback();
      return;
    }

    setState(() {
      _recording = true;
      _speechListening = true;
      _speechPartialResult = '';
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() => _speechPartialResult = result.recognizedWords);
        if (result.finalResult) {
          setState(() {
            _recording = false;
            _speechListening = false;
          });
          _applyTranscriptionResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: _speechLocaleId!, // ← locale verificado
      cancelOnError: false,
      partialResults: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> _stopNativeSpeech() async {
    await _speechToText.stop();
    setState(() {
      _recording = false;
      _speechListening = false;
    });
    // onStatus 'done' vai chamar _onSpeechDone automaticamente
    // mas chamamos aqui também como garantia
    if (_speechPartialResult.isNotEmpty) {
      _applyTranscriptionResult(_speechPartialResult);
    } else {
      _applyFallback();
    }
  }

  void _onSpeechDone() {
    if (_speechPartialResult.isNotEmpty) {
      _applyTranscriptionResult(_speechPartialResult);
    } else {
      _applyFallback();
    }
  }

  // ── Aplicar resultado da transcrição ──────────────────────────────────────
  void _applyTranscriptionResult(String transcribed) {
    if (_current == null) return;
    final similarity = TextSimilarity.calculate(transcribed, _current!.front);
    setState(() {
      _transcribedText = transcribed;
      _similarityRatio = similarity;
      _transcribing = false;
      _recording = false;
      _speechListening = false;
      _flipped = true;
    });
  }

  void _applyFallback() {
    setState(() {
      _transcribedText = null;
      _similarityRatio = 0;
      _transcribing = false;
      _recording = false;
      _speechListening = false;
      _flipped = true;
    });
  }

  // ── Submit Review ─────────────────────────────────────────────────────────────────
  Future<void> _submitReview(int score) async {
    if (_current == null || _submitting) return;
    setState(() => _submitting = true);

    final db = ref.read(databaseProvider);
    final cardId = _current!.id;

    // Actualizar SM-2 localmente (funciona offline)
    await db.cardDao.applySM2(cardId, widget.mode, score);

    if (_isOnline) {
      try {
        await ref
            .read(apiClientProvider)
            .submitReview(
              sessionId: widget.sessionId,
              cardId: cardId,
              score: score,
              similarityScore: widget.mode == 'Speaking' ? _similarityRatio : null,
              transcribedText: _transcribedText,
            );
      } catch (_) {
        // Guardar para sync posterior
        await db
            .into(db.pendingSyncTable)
            .insert(
              PendingSyncTableCompanion(
                operation: Value('submitReview'),
                payload: Value(
                  jsonEncode({
                    'sessionId': widget.sessionId,
                    'cardId': cardId,
                    'score': score,
                    'similarityScore': _similarityRatio,
                    'transcribedText': _transcribedText,
                  }),
                ),
                createdAt: Value(DateTime.now().toUtc()),
              ),
            );
      }
    } else {
      // Offline — guardar para sincronizar depois
      await _savePending(cardId, score);
    }

    setState(() {
      _currentIndex++;
      _flipped = false;
      _transcribedText = null;
      _similarityRatio = 0;
      _submitting = false;
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

  Future<void> _savePending(String cardId, int score) async {
    final db = ref.read(databaseProvider);
    await db.into(db.pendingSyncTable).insert(
      PendingSyncTableCompanion(
        operation: Value('submitReview'),
        payload: Value(jsonEncode({
          'sessionId': widget.sessionId,
          'cardId': cardId,
          'score': score,
          'similarityScore': _similarityRatio,
          'transcribedText': _transcribedText,
        })),
        createdAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> _endSession() async {
    try {
      if (_isOnline) {
        final result = await ref
            .read(apiClientProvider)
            .endSession(widget.sessionId);
        final reviewed = result['reviewedCards'] as int? ?? _reviewedCount;
        final average = (result['averageScore'] as num?)?.toDouble() ?? 0;
        if (mounted) {
          context.go(
            '/study/summary/${widget.sessionId}'
            '?reviewed=$reviewed&average=$average',
          );
        }
      } else {
        if (mounted) {
          context.go(
            '/study/summary/${widget.sessionId}'
            '?reviewed=$_reviewedCount&average=0',
          );
        }
      }
    } catch (_) {
      if (mounted) context.go('/decks');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UI
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_current == null && _cards.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentIndex >= _cards.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == 'Listening' ? '🎧 Listening' : '🗣️ Speaking',
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.stop, color: Colors.red),
            label: const Text(
              'Terminar',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _confirmEnd(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner offline
            if (!_isOnline)
              Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  const Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _speechAvailable
                          ? 'Offline — transcrição nativa activa'
                          : 'Modo offline — reviews serão sincronizadas',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ]),
              ),
        
            // Progress
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$_reviewedCount / ${_cards.length} cards', style: Theme.of(context).textTheme.bodySmall),
                    Text('${(_progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: const Color(0xFF594AE2))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8E5FF),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF594AE2)),
                  ),
                ),
              ]),
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
                        constraints: const BoxConstraints(minHeight: 160),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(
                            color: const Color(0xFF594AE2).withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_flipped) ...[
                              Text(_current!.front,
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center),
                              if (widget.mode == 'Listening' && _current!.audioPath != null) ...[
                                const SizedBox(height: 16),
                                IconButton.filled(
                                  icon: _isPlaying
                                      ? const SizedBox(width: 24, height: 24, child: MiniWaveformIcon())
                                      :  Icon(Icons.play_arrow),
                                  onPressed: () =>  _playAudio(_current!.audioPath!),
                                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF594AE2)),
                                ),
                              ],
                              const SizedBox(height: 12),
                              const Text('Toca para ver a resposta',
                                  style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ] else ...[
                              Text(_current!.back,
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF594AE2)),
                                  textAlign: TextAlign.center),
                              if (_current!.pronunciation != null) ...[
                                const SizedBox(height: 8),
                                Text('[${_current!.pronunciation}]',
                                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Speaking panel
                  if (widget.mode == 'Speaking') ...[
                    const SizedBox(height: 16),
                    _buildSpeakingPanel(),
                  ],

                  // Score buttons
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
      ),
    );
  }

  // ── Speaking panel ────────────────────────────────────────────────────────
  Widget _buildSpeakingPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: [

        // Badge do modo de transcrição
        _TranscriptionModeBadge(isOnline: _isOnline, speechAvailable: _speechAvailable),
        const SizedBox(height: 12),

        // Estado: idle
        if (!_recording && !_speechListening && _transcribedText == null && !_transcribing)
          FilledButton.icon(
            icon: const Icon(Icons.mic),
            label: const Text('Gravar'),
            onPressed: (_useNativeSpeech && _deckLang == null)
              ? ()=>{}
              : _startRecording,
          )

        // Estado: gravando (Whisper)
        else if (_recording && !_speechListening)
          _RecordingIndicator(label: 'A gravar...', onStop: _stopRecording)

        // Estado: speech_to_text a ouvir
        else if (_speechListening)
            _SpeechListeningIndicator(partialResult: _speechPartialResult, onStop: _stopRecording)

          // Estado: a transcrever
          else if (_transcribing)
              const _TranscribingIndicator()

            // Estado: resultado
            else if (_transcribedText != null)
                _TranscriptionResult(
                  text: _transcribedText!,
                  similarityRatio: _similarityRatio,
                  onRetry: () => setState(() {
                    _transcribedText = null;
                    _similarityRatio = 0;
                    _speechPartialResult = '';
                    _flipped = false;
                  }),
                ),
      ]),
    );
  }

  // ── Score buttons ─────────────────────────────────────────────────────────
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
          crossAxisCount:   3,
          shrinkWrap:       true,
          physics:          const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing:  8,
          childAspectRatio: 2.2,
          children: scores.map((s) => OutlinedButton(
            onPressed: _submitting ? null : () => _submitReview(s.$2),
            style: OutlinedButton.styleFrom(
              foregroundColor: s.$3,
              side: BorderSide(color: s.$3.withOpacity(0.5)),
              padding: EdgeInsets.zero,
            ),
            child: Text(s.$1,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center),
          )).toList(),
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
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Terminar')),
        ],
      ),
    );
    if (confirm == true) _endSession();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widgets auxiliares do painel de Speaking
// ══════════════════════════════════════════════════════════════════════════════

class _TranscriptionModeBadge extends StatelessWidget {
  final bool isOnline;
  final bool speechAvailable;
  const _TranscriptionModeBadge(
      {required this.isOnline, required this.speechAvailable});

  @override
  Widget build(BuildContext context) {
    final offline = !isOnline && speechAvailable;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          offline ? Icons.offline_bolt : Icons.cloud_done,
          size:  14,
          color: offline ? Colors.orange : Colors.green,
        ),
        const SizedBox(width: 6),
        Text(
          offline ? 'Transcrição nativa (offline)' : 'Transcrição via API',
          style: TextStyle(
            fontSize: 11,
            color: offline ? Colors.orange : Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RecordingIndicator extends StatelessWidget {
  final String    label;
  final VoidCallback onStop;
  const _RecordingIndicator(
      {required this.label, required this.onStop});

  @override
  Widget build(BuildContext context) => Column(children: [
    const SizedBox(
        width: 32, height: 32,
        child: CircularProgressIndicator(
            strokeWidth: 3, color: Colors.red)),
    const SizedBox(height: 8),
    Text(label,
        style: const TextStyle(color: Colors.red, fontSize: 13)),
    const SizedBox(height: 8),
    OutlinedButton.icon(
      icon:     const Icon(Icons.stop, color: Colors.red),
      label:    const Text('Parar',
          style: TextStyle(color: Colors.red)),
      onPressed: onStop,
    ),
  ]);
}

class _SpeechListeningIndicator extends StatelessWidget {
  final String       partialResult;
  final VoidCallback onStop;
  const _SpeechListeningIndicator(
      {required this.partialResult, required this.onStop});

  @override
  Widget build(BuildContext context) => Column(children: [
    const _PulsingMic(),
    const SizedBox(height: 8),
    const Text('A ouvir...',
        style: TextStyle(color: Color(0xFF594AE2), fontSize: 13)),
    if (partialResult.isNotEmpty) ...[
      const SizedBox(height: 8),
      Container(
        padding:     const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:        const Color(0xFFF0EDFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          partialResult,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF594AE2)),
        ),
      ),
    ],
    const SizedBox(height: 8),
    OutlinedButton.icon(
      icon:     const Icon(Icons.stop,
          color: Color(0xFF594AE2)),
      label:    const Text('Parar',
          style: TextStyle(color: Color(0xFF594AE2))),
      onPressed: onStop,
    ),
  ]);
}

class _PulsingMic extends StatefulWidget {
  const _PulsingMic();

  @override
  State<_PulsingMic> createState() => _PulsingMicState();
}

class _PulsingMicState extends State<_PulsingMic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(
        vsync:    this,
        duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _scale = Tween(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: Container(
      width:  52, height: 52,
      decoration: BoxDecoration(
        color:  const Color(0xFF594AE2).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.mic,
          color: Color(0xFF594AE2), size: 28),
    ),
  );
}

class _TranscribingIndicator extends StatelessWidget {
  const _TranscribingIndicator();

  @override
  Widget build(BuildContext context) => const Column(children: [
    CircularProgressIndicator(),
    SizedBox(height: 8),
    Text('A transcrever...', style: TextStyle(fontSize: 13)),
  ]);
}

class _TranscriptionResult extends StatelessWidget {
  final String    text;
  final double    similarityRatio;
  final VoidCallback onRetry;
  const _TranscriptionResult({
    required this.text,
    required this.similarityRatio,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final pct   = (similarityRatio * 100).toInt();
    final color = similarityRatio >= 0.85 ? Colors.green
        : similarityRatio >= 0.60 ? Colors.orange
        : Colors.red;

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Você disse:',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          Chip(
            label: Text('$pct%',
                style: TextStyle(color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            backgroundColor:      color.withOpacity(0.1),
            side:                 BorderSide(color: color.withOpacity(0.3)),
            padding:              const EdgeInsets.symmetric(horizontal: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity:        VisualDensity.compact,
          ),
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
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16)),
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value:           similarityRatio,
          minHeight:       6,
          backgroundColor: Colors.grey.shade200,
          valueColor:      AlwaysStoppedAnimation(color),
        ),
      ),
      TextButton.icon(
        icon:     const Icon(Icons.refresh, size: 16),
        label:    const Text('Tentar novamente'),
        onPressed: onRetry,
      ),
    ]);
  }
}