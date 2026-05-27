import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dto/deck_dto.dart';
import '../../data/dto/study_dto.dart';
import '../decks/deck_provider.dart';

class HomeSummary {
  final List<DeckDto> decks;
  final Map<String, DashboardDto?> dashboards;

  const HomeSummary({required this.decks, required this.dashboards});

  int get totalDueToday =>
      dashboards.values.fold(0, (s, d) => s + (d?.dueToday ?? 0));
  int get totalCards =>
      dashboards.values.fold(0, (s, d) => s + (d?.totalCards ?? 0));
  int get studiedToday =>
      dashboards.values.fold(0, (s, d) => s + (d?.studiedToday ?? 0));
}

final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  final decks = await ref.read(decksProvider.future);
  final dashboards = <String, DashboardDto?>{};

  await Future.wait(
    decks.map((d) async {
      dashboards[d.id] = await ref
          .read(deckRepositoryProvider)
          .getDashboard(d.id);
    }),
  );

  return HomeSummary(decks: decks, dashboards: dashboards);
});
