import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../data/repositories/study_repository.dart';
import '../auth/auth_provider.dart';

final studyRepositoryProvider = Provider<StudyRepository>(
  (ref) => StudyRepository(ref.read(apiClientProvider), ref.read(databaseProvider)),
);
