import 'package:fluentflow/shared/widgets/ff_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'deck_provider.dart';
import '../../shared/widgets/ff_loading.dart';

class DeckDetailPage extends ConsumerWidget {
  final String deckId;
  const DeckDetailPage({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);
    final dashboard = ref.watch(dashboardProvider(deckId));

    return Scaffold(
      appBar: FFAppBar(
        title: 'Detalhes do Deck',
        showBack: true,
        // onBack opcional — usa context.pop() por defeito
      ),
      body: decks.when(
        loading: () => const FFLoading(),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (list) {
          final deck = list.where((d) => d.id == deckId).firstOrNull;
          if (deck == null) {
            return const Center(child: Text('Deck não encontrado.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                deck.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${deck.language.toUpperCase()} → ${deck.nativeLanguage.toUpperCase()}',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // Dashboard
              dashboard.when(
                loading: () => const FFLoading(),
                error: (_, __) => const SizedBox.shrink(),
                data: (dash) => dash == null
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          Row(
                            children: [
                              _Stat('Total', '${dash.totalCards}'),
                              _Stat(
                                'Hoje',
                                '${dash.dueToday}',
                                color: Colors.orange,
                              ),
                              _Stat(
                                'Novas',
                                '${dash.newToday}',
                                color: Colors.blue,
                              ),
                              _Stat(
                                'Estudadas',
                                '${dash.studiedToday}',
                                color: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),

              // Botões de estudo
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.headphones),
                      label: const Text('Listening'),
                      onPressed: () =>
                          context.go('/study/$deckId/plan', extra: 'Listening'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.mic),
                      label: const Text('Speaking'),
                      onPressed: () =>
                          context.go('/study/$deckId/plan', extra: 'Speaking'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF7B6EF5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(this.label, this.value, {this.color = const Color(0xFF594AE2)});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    ),
  );
}
