// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FluentFlow';

  @override
  String get appSubTitle => 'Fluency that goes with your vibe';

  @override
  String get socialCallbackAuthenticating => 'Authenticating...';

  @override
  String get socialCallbackError => 'Authentication error';

  @override
  String get socialCallbackRedirecting => 'Redirecting to login...';

  @override
  String get socialCallbackTokensNotReceived => 'Tokens not received.';

  @override
  String socialCallbackError2(String error) {
    return 'Callback error: $error';
  }

  @override
  String get authOr => 'or';

  @override
  String get authContinueWithMicrosoft => 'Continue with Microsoft';

  @override
  String authSocialLoginError(String error) {
    return 'Social login error: $error';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navDecks => 'My Decks';

  @override
  String get navSessions => 'Sessions';

  @override
  String get authLogin => 'Sign in';

  @override
  String get authLogout => 'Sign out';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authName => 'Full name';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Sign in to continue';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authContinueMicrosoft => 'Continue with Microsoft';

  @override
  String get authContinueGitHub => 'Continue with GitHub';

  @override
  String get authInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authSignIn => 'Sign in';

  @override
  String authSocialError(String error) {
    return 'Social login error: $error';
  }

  @override
  String get decksTitle => 'My Decks';

  @override
  String get decksNew => 'New Deck';

  @override
  String get decksNoDecks => 'You have no decks yet.';

  @override
  String decksTotalCards(int count) {
    return '$count cards';
  }

  @override
  String decksReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '$count review',
    );
    return '$_temp0';
  }

  @override
  String decksNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new',
      one: '$count new',
    );
    return '$_temp0';
  }

  @override
  String get decksDueToday => 'Due today';

  @override
  String get decksNewToday => 'New today';

  @override
  String get decksStudiedToday => 'Studied today';

  @override
  String get decksDetailTitle => 'Deck Detail';

  @override
  String get decksNotFound => 'Deck not found.';

  @override
  String get decksNoCards => 'No cards in this deck.';

  @override
  String get studyPlan => 'Study Plan';

  @override
  String get studyMode => 'Study mode';

  @override
  String get studyListening => 'Listening';

  @override
  String get studySpeaking => 'Speaking';

  @override
  String get studyStarting => 'Starting...';

  @override
  String get studyStartError => 'Error starting session.';

  @override
  String get studyStart => 'Start session';

  @override
  String get studyEnd => 'End session';

  @override
  String get studyEndConfirm => 'Are you sure you want to end this session?';

  @override
  String get studyHowDidItGo => 'How did it go?';

  @override
  String get studyTapToReveal => 'Tap to reveal answer';

  @override
  String get studyScore0 => 'Blackout (0)';

  @override
  String get studyScore1 => 'Wrong (1)';

  @override
  String get studyScore2 => 'Hard (2)';

  @override
  String get studyScore3 => 'Ok (3)';

  @override
  String get studyScore4 => 'Good (4)';

  @override
  String get studyScore5 => 'Easy (5)';

  @override
  String get studyComplete => 'Session complete!';

  @override
  String get studyGoHome => 'Go home';

  @override
  String get studyGoDecks => 'View my decks';

  @override
  String get studyReviewedCards => 'Cards reviewed';

  @override
  String get studyAverageScore => 'Average score';

  @override
  String studyEndSummary(int reviewed, int total) {
    return '$reviewed of $total cards reviewed will be saved.';
  }

  @override
  String get studyRecord => 'Record';

  @override
  String get studyStop => 'Stop';

  @override
  String get studyRecording => 'Recording...';

  @override
  String get studyTranscribing => 'Transcribing...';

  @override
  String get studyListeningState => 'Listening...';

  @override
  String get studyNativeTranscription => 'Native transcription (offline)';

  @override
  String get studyApiTranscription => 'Transcription via API';

  @override
  String get studyYouSaid => 'You said:';

  @override
  String get studyTryAgain => 'Try again';

  @override
  String get studyNoCards => 'No cards to review today in this mode.';

  @override
  String get studyOfflineNative => 'Offline — native transcription active';

  @override
  String get studyOfflineReviews => 'Offline mode — reviews will be synced';

  @override
  String get studyListeningEmoji => '🎧 Listening';

  @override
  String get studySpeakingEmoji => '🗣️ Speaking';

  @override
  String get sessionsTitle => 'Study Sessions';

  @override
  String get sessionsAll => 'All';

  @override
  String get sessionsDuration => 'Duration';

  @override
  String get sessionsNoSessions => 'No sessions found.';

  @override
  String get sessionsDetailTitle => 'Session Detail';

  @override
  String get sessionsNotFound => 'Session not found.';

  @override
  String get sessionsScoreDistribution => 'Score distribution';

  @override
  String sessionsReviewedCount(int count) {
    return 'Cards reviewed ($count)';
  }

  @override
  String sessionsIntervalChange(int prev, int next) {
    return 'Interval: ${prev}d → ${next}d';
  }

  @override
  String sessionsReviewedCards(int reviewed, int total) {
    return 'Cards reviewed $reviewed of $total';
  }

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileName => 'Full name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileCurrentPassword => 'Current password';

  @override
  String get profileNewPassword => 'New password';

  @override
  String get profileSave => 'Save changes';

  @override
  String get profileRemovePhoto => 'Remove photo';

  @override
  String get profileAvatarTooBig => 'Image too large. Maximum 200 KB.';

  @override
  String get commonHello => 'Hi';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonOk => 'Ok';

  @override
  String get commonError => 'An error occurred. Please try again.';

  @override
  String get commonStudy => 'Study';

  @override
  String get commonDetails => 'View details';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonUpToDate => 'Up to date';

  @override
  String get commonToday => 'Today';

  @override
  String get commonNew => 'New';

  @override
  String get commonStudied => 'Studied';

  @override
  String get commonOr => 'or';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonPlay => 'Play';

  @override
  String commonAudioError(String error) {
    return 'Error playing audio: $error';
  }

  @override
  String get commonCards => 'cards';

  @override
  String get commonScore => 'score';

  @override
  String get cefrA1 => 'Beginner';

  @override
  String get cefrA2 => 'Elementary';

  @override
  String get cefrB1 => 'Intermediate';

  @override
  String get cefrB2 => 'Upper Intermediate';

  @override
  String get cefrC1 => 'Advanced';

  @override
  String get cefrC2 => 'Proficient';

  @override
  String get offlineBanner => 'Offline mode — changes will be synced';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutDescription =>
      'FluentFlow is a spaced repetition study platform focused on listening and speaking.';

  @override
  String get aboutWebNote =>
      'To add, edit or remove cards and decks, use the Web version of FluentFlow.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get homeSubtitle =>
      'Listening, speaking and spaced repetition (SM‑2) in a continuous learning flow, with smart dashboards and real feedback on your progress.';

  @override
  String get homeStartNow => 'Start now';

  @override
  String get homeAlreadyHaveAccount => 'I already have an account';

  @override
  String get homeSmartDashboard => 'Smart Dashboard';

  @override
  String get homeTrackDailyProgress => 'Track your daily progress';

  @override
  String get homeAverageEf => 'Average EF';

  @override
  String get homeProgress30Days => 'Progress (last 30 days)';

  @override
  String get homeSpeakingSession => 'Speaking Session';

  @override
  String get homeWhyDifferent => 'Why is FluentFlow different?';

  @override
  String get homeFeatureMultimodal => 'Multimodal study';

  @override
  String get homeFeatureMultimodalDesc =>
      'Listening and speaking in the same deck, with separate metrics and unified history.';

  @override
  String get homeFeatureSm2 => 'Real SM‑2';

  @override
  String get homeFeatureSm2Desc =>
      'Intervals, EF and repetitions calculated with the original spaced repetition algorithm.';

  @override
  String get homeFeatureDashboards => 'Actionable dashboards';

  @override
  String get homeFeatureDashboardsDesc =>
      'Daily activity, score distribution, new/due/overdue and daily planning.';

  @override
  String get homeFeaturePronunciation => 'Pronunciation feedback';

  @override
  String get homeFeaturePronunciationDesc =>
      'Real‑time Levenshtein similarity — know exactly where to improve.';

  @override
  String get homeHowItWorks => 'How does it work?';

  @override
  String get homeStepCreateAccount => 'Create your account.';

  @override
  String get homeStepCreateAccountDesc =>
      'Secure access with JWT or social login.';

  @override
  String get homeStepCreateDeck => 'Create a deck and upload audio.';

  @override
  String get homeStepCreateDeckDesc => 'Whisper transcribes automatically.';

  @override
  String get homeStepShortSessions => 'Study in short sessions.';

  @override
  String get homeStepShortSessionsDesc =>
      'The system selects new, due and overdue cards.';

  @override
  String get homeStepTrackDashboard => 'Follow the dashboard.';

  @override
  String get homeStepTrackDashboardDesc =>
      'Adjust your pace based on the last 30 days.';

  @override
  String get homeCtaTitle => 'Ready to put your English into flow?';

  @override
  String get homeCtaSubtitle =>
      'Create your account and start improving today.';

  @override
  String get homeCtaButton => 'Create free account';

  @override
  String get navPodcasts => 'Podcasts';

  @override
  String get commonRetry => 'Retry';

  @override
  String studyRepeatCount(int current, int total) {
    return 'Repeat $current/$total';
  }

  @override
  String get studySpeed => 'Speed';

  @override
  String get podcastsAudioError => 'Could not play the audio.';

  @override
  String get podcastsAutoNext => 'Autoplay next episode';

  @override
  String get podcastsContinue => 'Continue';

  @override
  String get podcastsContinueListening => 'Continue where you left off';

  @override
  String get podcastsEmpty =>
      'You have no episodes yet. Upload the PodcastGenerator files on the website (Podcasts → Upload episodes).';

  @override
  String get podcastsEpisodeFinished => 'Episode finished!';

  @override
  String get podcastsFavorite => 'Favorite';

  @override
  String get podcastsFilterAll => 'All';

  @override
  String get podcastsFilterCompleted => 'Listened';

  @override
  String get podcastsFilterFavorites => 'Favorites';

  @override
  String get podcastsFilterInProgress => 'In progress';

  @override
  String get podcastsFilterNotStarted => 'Not listened';

  @override
  String get podcastsFollowText => 'Follow along';

  @override
  String get podcastsGeneral => 'General';

  @override
  String podcastsGroupProgress(int completed, int total) {
    return '$completed of $total listened';
  }

  @override
  String get podcastsHomeSubtitle => 'Everyday dialogues with synced text';

  @override
  String get podcastsListen => 'Listen';

  @override
  String get podcastsListenAgain => 'Listen again';

  @override
  String get podcastsMarkListened => 'Mark as listened';

  @override
  String get podcastsMarkUnlistened => 'Mark as not listened';

  @override
  String get podcastsMarkedListened => 'Episode marked as listened.';

  @override
  String get podcastsMarkedUnlistened => 'Episode marked as not listened.';

  @override
  String get podcastsNextEpisode => 'Next episode';

  @override
  String podcastsNextIn(String title, int seconds) {
    return 'Next: $title in ${seconds}s';
  }

  @override
  String get podcastsNextLine => 'Next line';

  @override
  String get podcastsNoMatches => 'No episodes match the filters.';

  @override
  String get podcastsPlayNow => 'Play now';

  @override
  String get podcastsPreviousEpisode => 'Previous episode';

  @override
  String get podcastsPreviousLine => 'Previous line';

  @override
  String get podcastsRepeatLine => 'Repeat current line';

  @override
  String get podcastsRestart => 'Start over';

  @override
  String podcastsResumePrompt(String position) {
    return 'You stopped at $position. Continue or start over?';
  }

  @override
  String podcastsSeason(int season) {
    return 'Season $season';
  }

  @override
  String get podcastsSectionDialogue => 'Dialogue';

  @override
  String get podcastsSectionIntro => 'Intro';

  @override
  String get podcastsSectionOutro => 'Wrap-up';

  @override
  String get podcastsSectionReview => 'Review';

  @override
  String get podcastsSettings => 'Player settings';

  @override
  String get podcastsShowTranslation => 'Show translation';

  @override
  String podcastsSlowVersion(String tempo) {
    return 'Slow version ($tempo)';
  }

  @override
  String get podcastsSpeed => 'Speed';

  @override
  String get podcastsStatsCompleted => 'Episodes listened';

  @override
  String get podcastsStatsInProgress => 'In progress';

  @override
  String get podcastsStatsMinutes => 'Minutes listened';

  @override
  String podcastsStoppedAt(String position, String duration) {
    return 'Stopped at $position of $duration';
  }

  @override
  String get podcastsSubtitle =>
      'Listen to everyday dialogues and follow the text line by line.';

  @override
  String podcastsTimesListened(int count) {
    return 'Listened $count×';
  }

  @override
  String get podcastsTitle => 'Podcasts';

  @override
  String get podcastsUpNext => 'Up next';

  @override
  String get podcastsDelete => 'Delete episode';

  @override
  String podcastsDeleteConfirm(String title) {
    return 'Delete the episode \"$title\"? Its audio files and progress will be removed.';
  }

  @override
  String get podcastsDeleted => 'Episode deleted.';
}
