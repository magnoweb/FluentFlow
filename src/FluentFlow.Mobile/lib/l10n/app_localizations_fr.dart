// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FluentFlow';

  @override
  String get appSubTitle => 'Une fluidité qui suit ton rythme';

  @override
  String get socialCallbackAuthenticating => 'Authentification en cours...';

  @override
  String get socialCallbackError => 'Erreur d\'authentification';

  @override
  String get socialCallbackRedirecting => 'Redirection vers la connexion...';

  @override
  String get socialCallbackTokensNotReceived => 'Tokens non reçus.';

  @override
  String socialCallbackError2(String error) {
    return 'Erreur de callback : $error';
  }

  @override
  String get authOr => 'ou';

  @override
  String get authContinueWithMicrosoft => 'Continuer avec Microsoft';

  @override
  String authSocialLoginError(String error) {
    return 'Erreur de connexion sociale : $error';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navDecks => 'Mes Decks';

  @override
  String get navSessions => 'Sessions';

  @override
  String get authLogin => 'Se connecter';

  @override
  String get authLogout => 'Se déconnecter';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authName => 'Nom complet';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authLoginSubtitle => 'Connectez-vous pour continuer';

  @override
  String get authContinueGoogle => 'Continuer avec Google';

  @override
  String get authContinueMicrosoft => 'Continuer avec Microsoft';

  @override
  String get authContinueGitHub => 'Continuer avec GitHub';

  @override
  String get authInvalidCredentials => 'Email ou mot de passe incorrect.';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String authSocialError(String error) {
    return 'Erreur de connexion sociale : $error';
  }

  @override
  String get decksTitle => 'Mes Decks';

  @override
  String get decksNew => 'Nouveau Deck';

  @override
  String get decksNoDecks => 'Vous n\'avez pas encore de decks.';

  @override
  String decksTotalCards(int count) {
    return '$count cartes';
  }

  @override
  String decksReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count révisions',
      one: '$count révision',
    );
    return '$_temp0';
  }

  @override
  String decksNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouvelles',
      one: '$count nouvelle',
    );
    return '$_temp0';
  }

  @override
  String get decksDueToday => 'À réviser aujourd\'hui';

  @override
  String get decksNewToday => 'Nouvelles aujourd\'hui';

  @override
  String get decksStudiedToday => 'Étudiées aujourd\'hui';

  @override
  String get decksDetailTitle => 'Détail du Deck';

  @override
  String get decksNotFound => 'Deck introuvable.';

  @override
  String get decksNoCards => 'Aucune carte dans ce deck.';

  @override
  String get studyPlan => 'Plan d\'étude';

  @override
  String get studyMode => 'Mode d\'étude';

  @override
  String get studyListening => 'Écoute';

  @override
  String get studySpeaking => 'Expression orale';

  @override
  String get studyStarting => 'Démarrage...';

  @override
  String get studyStartError => 'Erreur lors du démarrage de la session.';

  @override
  String get studyStart => 'Démarrer la session';

  @override
  String get studyEnd => 'Terminer la session';

  @override
  String get studyEndConfirm =>
      'Êtes-vous sûr de vouloir terminer cette session ?';

  @override
  String get studyHowDidItGo => 'Comment ça s\'est passé ?';

  @override
  String get studyTapToReveal => 'Cliquez pour révéler la réponse';

  @override
  String get studyScore0 => 'Échec total (0)';

  @override
  String get studyScore1 => 'Incorrect (1)';

  @override
  String get studyScore2 => 'Difficile (2)';

  @override
  String get studyScore3 => 'Ok (3)';

  @override
  String get studyScore4 => 'Bien (4)';

  @override
  String get studyScore5 => 'Facile (5)';

  @override
  String get studyComplete => 'Session terminée !';

  @override
  String get studyGoHome => 'Aller à l\'accueil';

  @override
  String get studyGoDecks => 'Voir mes decks';

  @override
  String get studyReviewedCards => 'Cartes révisées';

  @override
  String get studyAverageScore => 'Score moyen';

  @override
  String studyEndSummary(int reviewed, int total) {
    return '$reviewed sur $total cartes révisées seront enregistrées.';
  }

  @override
  String get studyRecord => 'Enregistrer';

  @override
  String get studyStop => 'Arrêter';

  @override
  String get studyRecording => 'Enregistrement...';

  @override
  String get studyTranscribing => 'Transcription...';

  @override
  String get studyListeningState => 'Écoute...';

  @override
  String get studyNativeTranscription => 'Transcription native (hors ligne)';

  @override
  String get studyApiTranscription => 'Transcription via API';

  @override
  String get studyYouSaid => 'Vous avez dit :';

  @override
  String get studyTryAgain => 'Réessayer';

  @override
  String get studyNoCards =>
      'Aucune carte à réviser aujourd\'hui dans ce mode.';

  @override
  String get studyOfflineNative => 'Hors ligne — transcription native active';

  @override
  String get studyOfflineReviews =>
      'Mode hors ligne — les révisions seront synchronisées';

  @override
  String get studyListeningEmoji => '🎧 Écoute';

  @override
  String get studySpeakingEmoji => '🗣️ Expression orale';

  @override
  String get sessionsTitle => 'Sessions d\'étude';

  @override
  String get sessionsAll => 'Toutes';

  @override
  String get sessionsDuration => 'Durée';

  @override
  String get sessionsNoSessions => 'Aucune session trouvée.';

  @override
  String get sessionsDetailTitle => 'Détail de la Session';

  @override
  String get sessionsNotFound => 'Session introuvable.';

  @override
  String get sessionsScoreDistribution => 'Distribution des scores';

  @override
  String sessionsReviewedCount(int count) {
    return 'Cartes révisées ($count)';
  }

  @override
  String sessionsIntervalChange(int prev, int next) {
    return 'Intervalle : ${prev}j → ${next}j';
  }

  @override
  String sessionsReviewedCards(int reviewed, int total) {
    return 'Cartes révisées $reviewed sur $total';
  }

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileName => 'Nom complet';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileChangePassword => 'Changer le mot de passe';

  @override
  String get profileCurrentPassword => 'Mot de passe actuel';

  @override
  String get profileNewPassword => 'Nouveau mot de passe';

  @override
  String get profileSave => 'Enregistrer les modifications';

  @override
  String get profileRemovePhoto => 'Supprimer la photo';

  @override
  String get profileAvatarTooBig => 'Image trop grande. Maximum 200 KB.';

  @override
  String get commonHello => 'Bonjour';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonOk => 'Ok';

  @override
  String get commonError => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get commonStudy => 'Étudier';

  @override
  String get commonDetails => 'Voir les détails';

  @override
  String get commonLanguage => 'Langue';

  @override
  String get commonUpToDate => 'À jour';

  @override
  String get commonToday => 'Aujourd\'hui';

  @override
  String get commonNew => 'Nouvelles';

  @override
  String get commonStudied => 'Étudiées';

  @override
  String get commonOr => 'ou';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonPlay => 'Lire';

  @override
  String commonAudioError(String error) {
    return 'Erreur lors de la lecture de l\'audio : $error';
  }

  @override
  String get commonCards => 'cartes';

  @override
  String get commonScore => 'score';

  @override
  String get cefrA1 => 'Débutant';

  @override
  String get cefrA2 => 'Élémentaire';

  @override
  String get cefrB1 => 'Intermédiaire';

  @override
  String get cefrB2 => 'Intermédiaire supérieur';

  @override
  String get cefrC1 => 'Avancé';

  @override
  String get cefrC2 => 'Compétent';

  @override
  String get offlineBanner =>
      'Mode hors ligne — les modifications seront synchronisées';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutDescription =>
      'FluentFlow est une plateforme d\'étude avec répétition espacée, axée sur l\'écoute et l\'expression orale.';

  @override
  String get aboutWebNote =>
      'Pour ajouter, modifier ou supprimer des cartes et des decks, utilisez la version Web de FluentFlow.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get homeSubtitle =>
      'Écoute, expression orale et répétition espacée (SM‑2) dans un flux d’apprentissage continu, avec des tableaux de bord intelligents et un retour réel sur vos progrès.';

  @override
  String get homeStartNow => 'Commencer maintenant';

  @override
  String get homeAlreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get homeSmartDashboard => 'Tableau de bord intelligent';

  @override
  String get homeTrackDailyProgress => 'Suivez vos progrès quotidiens';

  @override
  String get homeAverageEf => 'EF moyen';

  @override
  String get homeProgress30Days => 'Progrès (30 derniers jours)';

  @override
  String get homeSpeakingSession => 'Session d\'expression orale';

  @override
  String get homeWhyDifferent => 'Pourquoi FluentFlow est différent ?';

  @override
  String get homeFeatureMultimodal => 'Étude multimodale';

  @override
  String get homeFeatureMultimodalDesc =>
      'Écoute et expression orale dans le même deck, avec des métriques séparées et un historique unifié.';

  @override
  String get homeFeatureSm2 => 'SM‑2 réel';

  @override
  String get homeFeatureSm2Desc =>
      'Intervalles, EF et répétitions calculés avec l’algorithme original de répétition espacée.';

  @override
  String get homeFeatureDashboards => 'Tableaux de bord exploitables';

  @override
  String get homeFeatureDashboardsDesc =>
      'Activité quotidienne, distribution des scores, nouvelles/due/overdue et planification du jour.';

  @override
  String get homeFeaturePronunciation => 'Retour sur la prononciation';

  @override
  String get homeFeaturePronunciationDesc =>
      'Similarité de Levenshtein en temps réel — vous savez exactement où progresser.';

  @override
  String get homeHowItWorks => 'Comment ça fonctionne ?';

  @override
  String get homeStepCreateAccount => 'Créez votre compte.';

  @override
  String get homeStepCreateAccountDesc =>
      'Accès sécurisé avec JWT ou connexion sociale.';

  @override
  String get homeStepCreateDeck => 'Créez un deck et importez un audio.';

  @override
  String get homeStepCreateDeckDesc => 'Whisper transcrit automatiquement.';

  @override
  String get homeStepShortSessions => 'Étudiez en sessions courtes.';

  @override
  String get homeStepShortSessionsDesc =>
      'Le système sélectionne les nouvelles cartes, les dues et les en retard.';

  @override
  String get homeStepTrackDashboard => 'Suivez le tableau de bord.';

  @override
  String get homeStepTrackDashboardDesc =>
      'Ajustez votre rythme selon les 30 derniers jours.';

  @override
  String get homeCtaTitle => 'Prêt à mettre votre anglais en mouvement ?';

  @override
  String get homeCtaSubtitle =>
      'Créez votre compte et commencez à progresser dès aujourd’hui.';

  @override
  String get homeCtaButton => 'Créer un compte gratuit';
}
