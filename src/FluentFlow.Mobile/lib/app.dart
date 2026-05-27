import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/login_page.dart';
import 'features/auth/auth_provider.dart';
import 'features/home/home_page.dart';
import 'features/decks/deck_list_page.dart';
import 'features/decks/deck_detail_page.dart';
import 'features/study/study_plan_page.dart';
import 'features/study/study_session_page.dart';
import 'features/study/study_summary_page.dart';
import 'shared/theme/app_theme.dart';

const _publicRoutes = ['/login'];

GoRouter _buildRouter(WidgetRef ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isPublic = _publicRoutes.contains(state.matchedLocation);

      if (!isAuthenticated && !isPublic) return '/login';
      if (isAuthenticated && isPublic) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(path: '/decks', builder: (_, __) => const DeckListPage()),
      GoRoute(
        path: '/decks/:id',
        builder: (_, state) =>
            DeckDetailPage(deckId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/study/:deckId/plan',
        builder: (_, state) =>
            StudyPlanPage(deckId: state.pathParameters['deckId']!),
      ),
      GoRoute(
        path: '/study/:sessionId/:deckId/:mode',
        builder: (_, state) => StudySessionPage(
          sessionId: state.pathParameters['sessionId']!,
          deckId: state.pathParameters['deckId']!,
          mode: state.pathParameters['mode']!,
        ),
      ),
      GoRoute(
        path: '/study/summary/:sessionId',
        builder: (_, state) => StudySummaryPage(
          sessionId: state.pathParameters['sessionId']!,
          reviewed:
              int.tryParse(state.uri.queryParameters['reviewed'] ?? '0') ?? 0,
          average:
              double.tryParse(state.uri.queryParameters['average'] ?? '0') ??
              0.0,
        ),
      ),
    ],
  );
}

class FluentFlowApp extends ConsumerWidget {
  const FluentFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FluentFlow',
      theme: AppTheme.light,
      routerConfig: _buildRouter(ref),
      debugShowCheckedModeBanner: false,
    );
  }
}
