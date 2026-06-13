import 'package:fluentflow/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final decks = ref.watch(decksProvider);

    return Scaffold(
      appBar: FFAppBar(title: l10n.decksTitle),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(decksProvider.future),
        child: decks.when(
          loading: () => const FFLoading(),
          error: (e, _) => Center(child: Text('${l10n.commonError}: $e')),
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
                      Text(
                        '${l10n.decksNoDecks} ${l10n.aboutWebNote}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
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
                          '${d.language.toUpperCase()} · ${l10n.decksTotalCards(d.totalCards)}',
                        ),
                        trailing: FilledButton(
                          onPressed: () => context.go('/study/${d.id}/plan'),
                          child: Text(l10n.commonStudy),
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
