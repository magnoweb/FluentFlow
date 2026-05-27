import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dto/deck_dto.dart';
import '../../data/dto/study_dto.dart';
import '../../data/repositories/deck_repository.dart';
import '../auth/auth_provider.dart';

final deckRepositoryProvider = Provider<DeckRepository>(
  (ref) =>
      DeckRepository(ref.read(apiClientProvider), ref.read(databaseProvider)),
);

// Lista de decks
final decksProvider = FutureProvider<List<DeckDto>>(
  (ref) => ref.read(deckRepositoryProvider).getDecks(),
);

// Dashboard por deck
final dashboardProvider = FutureProvider.family<DashboardDto?, String>(
  (ref, deckId) => ref.read(deckRepositoryProvider).getDashboard(deckId),
);
