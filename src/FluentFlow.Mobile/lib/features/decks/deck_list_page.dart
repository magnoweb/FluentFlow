import 'package:fluentflow/shared/widgets/ff_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'deck_provider.dart';
import '../../shared/widgets/ff_loading.dart';

class DeckListPage extends ConsumerWidget {
  const DeckListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);

    return Scaffold(
      appBar: FFAppBar(title: 'Os meus Decks'),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(decksProvider.future),
        child: decks.when(
          loading: () => const FFLoading(),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (list) => list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.library_books_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sem decks. Crie um na versão Web.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final d = list[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(d.name),
                        subtitle: Text(
                          '${d.language.toUpperCase()} · ${d.totalCards} cards',
                        ),
                        trailing: FilledButton(
                          onPressed: () => context.go('/study/${d.id}/plan'),
                          child: const Text('Estudar'),
                        ),
                        onTap: () => context.go('/decks/${d.id}'),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
