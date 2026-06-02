import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fluentflow/shared/widgets/ff_app_bar.dart';
import 'study_provider.dart';
import '../../shared/widgets/ff_loading.dart';

class StudyPlanPage extends ConsumerStatefulWidget {
  final String deckId;
  const StudyPlanPage({super.key, required this.deckId});

  @override
  ConsumerState<StudyPlanPage> createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends ConsumerState<StudyPlanPage> {
  String _mode = 'Listening';
  bool _loading = false;

  Future<void> _startSession() async {
    setState(() => _loading = true);
    final repo = ref.read(studyRepositoryProvider);
    final sessionId = await repo.startSession(widget.deckId, _mode);

    if (!mounted) return;
    setState(() => _loading = false);

    if (sessionId != null) {
      context.go('/study/$sessionId/${widget.deckId}/$_mode');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao iniciar sessão.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FFAppBar(
        title: 'Plano de Estudo',
        showBack: true,
        // onBack opcional — usa context.pop() por defeito
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modo de estudo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Selector de modo
              Row(
                children: [
                  Expanded(
                    child: _ModeCard(
                      icon: Icons.headphones,
                      label: 'Listening',
                      selected: _mode == 'Listening',
                      onTap: () => setState(() => _mode = 'Listening'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModeCard(
                      icon: Icons.mic,
                      label: 'Speaking',
                      selected: _mode == 'Speaking',
                      onTap: () => setState(() => _mode = 'Speaking'),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_loading ? 'A iniciar...' : 'Iniciar sessão'),
                  onPressed: _loading ? null : _startSession,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF594AE2) : Colors.grey.shade200;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF594AE2).withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
              color: selected ? const Color(0xFF594AE2) : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? const Color(0xFF594AE2) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
