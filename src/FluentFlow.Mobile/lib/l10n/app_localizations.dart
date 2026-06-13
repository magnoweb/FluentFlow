import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'FluentFlow'**
  String get appTitle;

  /// No description provided for @appSubTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fluência que flui com o teu ritmo'**
  String get appSubTitle;

  /// No description provided for @socialCallbackAuthenticating.
  ///
  /// In pt, this message translates to:
  /// **'A autenticar...'**
  String get socialCallbackAuthenticating;

  /// No description provided for @socialCallbackError.
  ///
  /// In pt, this message translates to:
  /// **'Erro na autenticação'**
  String get socialCallbackError;

  /// No description provided for @socialCallbackRedirecting.
  ///
  /// In pt, this message translates to:
  /// **'A redirecionar para o login...'**
  String get socialCallbackRedirecting;

  /// No description provided for @socialCallbackTokensNotReceived.
  ///
  /// In pt, this message translates to:
  /// **'Tokens não recebidos.'**
  String get socialCallbackTokensNotReceived;

  /// No description provided for @socialCallbackError2.
  ///
  /// In pt, this message translates to:
  /// **'Erro no callback: {error}'**
  String socialCallbackError2(String error);

  /// No description provided for @authOr.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get authOr;

  /// No description provided for @authContinueWithMicrosoft.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Microsoft'**
  String get authContinueWithMicrosoft;

  /// No description provided for @authSocialLoginError.
  ///
  /// In pt, this message translates to:
  /// **'Erro no login social: {error}'**
  String authSocialLoginError(String error);

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navDecks.
  ///
  /// In pt, this message translates to:
  /// **'Os meus Decks'**
  String get navDecks;

  /// No description provided for @navSessions.
  ///
  /// In pt, this message translates to:
  /// **'Sessões'**
  String get navSessions;

  /// No description provided for @authLogin.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar sessão'**
  String get authLogin;

  /// No description provided for @authLogout.
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessão'**
  String get authLogout;

  /// No description provided for @authEmail.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In pt, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get authName;

  /// No description provided for @authWelcomeBack.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta'**
  String get authWelcomeBack;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Inicia sessão para continuar'**
  String get authLoginSubtitle;

  /// No description provided for @authContinueGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get authContinueGoogle;

  /// No description provided for @authContinueMicrosoft.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Microsoft'**
  String get authContinueMicrosoft;

  /// No description provided for @authContinueGitHub.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com GitHub'**
  String get authContinueGitHub;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'Email ou password incorrectos.'**
  String get authInvalidCredentials;

  /// No description provided for @authSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar sessão'**
  String get authSignIn;

  /// No description provided for @authSocialError.
  ///
  /// In pt, this message translates to:
  /// **'Erro no login social: {error}'**
  String authSocialError(String error);

  /// No description provided for @decksTitle.
  ///
  /// In pt, this message translates to:
  /// **'Os meus Decks'**
  String get decksTitle;

  /// No description provided for @decksNew.
  ///
  /// In pt, this message translates to:
  /// **'Novo Deck'**
  String get decksNew;

  /// No description provided for @decksNoDecks.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tens decks.'**
  String get decksNoDecks;

  /// No description provided for @decksTotalCards.
  ///
  /// In pt, this message translates to:
  /// **'{count} cards'**
  String decksTotalCards(int count);

  /// No description provided for @decksReviewCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{{count} revisão} other{{count} revisões}}'**
  String decksReviewCount(int count);

  /// No description provided for @decksNewCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{{count} nova} other{{count} novas}}'**
  String decksNewCount(int count);

  /// No description provided for @decksDueToday.
  ///
  /// In pt, this message translates to:
  /// **'Para rever hoje'**
  String get decksDueToday;

  /// No description provided for @decksNewToday.
  ///
  /// In pt, this message translates to:
  /// **'Novas hoje'**
  String get decksNewToday;

  /// No description provided for @decksStudiedToday.
  ///
  /// In pt, this message translates to:
  /// **'Estudadas hoje'**
  String get decksStudiedToday;

  /// No description provided for @decksDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhe do Deck'**
  String get decksDetailTitle;

  /// No description provided for @decksNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Deck não encontrado.'**
  String get decksNotFound;

  /// No description provided for @decksNoCards.
  ///
  /// In pt, this message translates to:
  /// **'Sem cards neste deck.'**
  String get decksNoCards;

  /// No description provided for @studyPlan.
  ///
  /// In pt, this message translates to:
  /// **'Plano de Estudo'**
  String get studyPlan;

  /// No description provided for @studyMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo de estudo'**
  String get studyMode;

  /// No description provided for @studyListening.
  ///
  /// In pt, this message translates to:
  /// **'Listening'**
  String get studyListening;

  /// No description provided for @studySpeaking.
  ///
  /// In pt, this message translates to:
  /// **'Speaking'**
  String get studySpeaking;

  /// No description provided for @studyStarting.
  ///
  /// In pt, this message translates to:
  /// **'A iniciar...'**
  String get studyStarting;

  /// No description provided for @studyStartError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao iniciar sessão.'**
  String get studyStartError;

  /// No description provided for @studyStart.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar sessão'**
  String get studyStart;

  /// No description provided for @studyEnd.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar sessão'**
  String get studyEnd;

  /// No description provided for @studyEndConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem a certeza que quer encerrar a sessão?'**
  String get studyEndConfirm;

  /// No description provided for @studyHowDidItGo.
  ///
  /// In pt, this message translates to:
  /// **'Como correu?'**
  String get studyHowDidItGo;

  /// No description provided for @studyTapToReveal.
  ///
  /// In pt, this message translates to:
  /// **'Clique para ver a resposta'**
  String get studyTapToReveal;

  /// No description provided for @studyScore0.
  ///
  /// In pt, this message translates to:
  /// **'Nada (0)'**
  String get studyScore0;

  /// No description provided for @studyScore1.
  ///
  /// In pt, this message translates to:
  /// **'Errei (1)'**
  String get studyScore1;

  /// No description provided for @studyScore2.
  ///
  /// In pt, this message translates to:
  /// **'Difícil (2)'**
  String get studyScore2;

  /// No description provided for @studyScore3.
  ///
  /// In pt, this message translates to:
  /// **'Ok (3)'**
  String get studyScore3;

  /// No description provided for @studyScore4.
  ///
  /// In pt, this message translates to:
  /// **'Bem (4)'**
  String get studyScore4;

  /// No description provided for @studyScore5.
  ///
  /// In pt, this message translates to:
  /// **'Fácil (5)'**
  String get studyScore5;

  /// No description provided for @studyComplete.
  ///
  /// In pt, this message translates to:
  /// **'Sessão concluída!'**
  String get studyComplete;

  /// No description provided for @studyGoHome.
  ///
  /// In pt, this message translates to:
  /// **'Ir para o início'**
  String get studyGoHome;

  /// No description provided for @studyGoDecks.
  ///
  /// In pt, this message translates to:
  /// **'Ver os meus decks'**
  String get studyGoDecks;

  /// No description provided for @studyReviewedCards.
  ///
  /// In pt, this message translates to:
  /// **'Cards revistos'**
  String get studyReviewedCards;

  /// No description provided for @studyAverageScore.
  ///
  /// In pt, this message translates to:
  /// **'Score médio'**
  String get studyAverageScore;

  /// No description provided for @studyEndSummary.
  ///
  /// In pt, this message translates to:
  /// **'{reviewed} de {total} cards revistos serão guardados.'**
  String studyEndSummary(int reviewed, int total);

  /// No description provided for @studyRecord.
  ///
  /// In pt, this message translates to:
  /// **'Gravar'**
  String get studyRecord;

  /// No description provided for @studyStop.
  ///
  /// In pt, this message translates to:
  /// **'Parar'**
  String get studyStop;

  /// No description provided for @studyRecording.
  ///
  /// In pt, this message translates to:
  /// **'A gravar...'**
  String get studyRecording;

  /// No description provided for @studyTranscribing.
  ///
  /// In pt, this message translates to:
  /// **'A transcrever...'**
  String get studyTranscribing;

  /// No description provided for @studyListeningState.
  ///
  /// In pt, this message translates to:
  /// **'A ouvir...'**
  String get studyListeningState;

  /// No description provided for @studyNativeTranscription.
  ///
  /// In pt, this message translates to:
  /// **'Transcrição nativa (offline)'**
  String get studyNativeTranscription;

  /// No description provided for @studyApiTranscription.
  ///
  /// In pt, this message translates to:
  /// **'Transcrição via API'**
  String get studyApiTranscription;

  /// No description provided for @studyYouSaid.
  ///
  /// In pt, this message translates to:
  /// **'Você disse:'**
  String get studyYouSaid;

  /// No description provided for @studyTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get studyTryAgain;

  /// No description provided for @studyNoCards.
  ///
  /// In pt, this message translates to:
  /// **'Não há cards para rever hoje neste modo.'**
  String get studyNoCards;

  /// No description provided for @studyOfflineNative.
  ///
  /// In pt, this message translates to:
  /// **'Offline — transcrição nativa activa'**
  String get studyOfflineNative;

  /// No description provided for @studyOfflineReviews.
  ///
  /// In pt, this message translates to:
  /// **'Modo offline — revisões serão sincronizadas'**
  String get studyOfflineReviews;

  /// No description provided for @studyListeningEmoji.
  ///
  /// In pt, this message translates to:
  /// **'🎧 Listening'**
  String get studyListeningEmoji;

  /// No description provided for @studySpeakingEmoji.
  ///
  /// In pt, this message translates to:
  /// **'🗣️ Speaking'**
  String get studySpeakingEmoji;

  /// No description provided for @sessionsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sessões de Estudo'**
  String get sessionsTitle;

  /// No description provided for @sessionsAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get sessionsAll;

  /// No description provided for @sessionsDuration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get sessionsDuration;

  /// No description provided for @sessionsNoSessions.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma sessão encontrada.'**
  String get sessionsNoSessions;

  /// No description provided for @sessionsDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhe da Sessão'**
  String get sessionsDetailTitle;

  /// No description provided for @sessionsNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Sessão não encontrada.'**
  String get sessionsNotFound;

  /// No description provided for @sessionsScoreDistribution.
  ///
  /// In pt, this message translates to:
  /// **'Distribuição de scores'**
  String get sessionsScoreDistribution;

  /// No description provided for @sessionsReviewedCount.
  ///
  /// In pt, this message translates to:
  /// **'Cards revistos ({count})'**
  String sessionsReviewedCount(int count);

  /// No description provided for @sessionsIntervalChange.
  ///
  /// In pt, this message translates to:
  /// **'Intervalo: {prev}d → {next}d'**
  String sessionsIntervalChange(int prev, int next);

  /// No description provided for @sessionsReviewedCards.
  ///
  /// In pt, this message translates to:
  /// **'Cards revistos {reviewed} de {total}'**
  String sessionsReviewedCards(int reviewed, int total);

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'O meu perfil'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileChangePassword.
  ///
  /// In pt, this message translates to:
  /// **'Alterar password'**
  String get profileChangePassword;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In pt, this message translates to:
  /// **'Password actual'**
  String get profileCurrentPassword;

  /// No description provided for @profileNewPassword.
  ///
  /// In pt, this message translates to:
  /// **'Nova password'**
  String get profileNewPassword;

  /// No description provided for @profileSave.
  ///
  /// In pt, this message translates to:
  /// **'Guardar alterações'**
  String get profileSave;

  /// No description provided for @profileRemovePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Remover foto'**
  String get profileRemovePhoto;

  /// No description provided for @profileAvatarTooBig.
  ///
  /// In pt, this message translates to:
  /// **'Imagem demasiado grande. Máximo 200 KB.'**
  String get profileAvatarTooBig;

  /// No description provided for @commonHello.
  ///
  /// In pt, this message translates to:
  /// **'Olá'**
  String get commonHello;

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In pt, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get commonBack;

  /// No description provided for @commonLoading.
  ///
  /// In pt, this message translates to:
  /// **'A carregar...'**
  String get commonLoading;

  /// No description provided for @commonOk.
  ///
  /// In pt, this message translates to:
  /// **'Ok'**
  String get commonOk;

  /// No description provided for @commonError.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro. Tente novamente.'**
  String get commonError;

  /// No description provided for @commonStudy.
  ///
  /// In pt, this message translates to:
  /// **'Estudar'**
  String get commonStudy;

  /// No description provided for @commonDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get commonDetails;

  /// No description provided for @commonLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get commonLanguage;

  /// No description provided for @commonUpToDate.
  ///
  /// In pt, this message translates to:
  /// **'Em dia'**
  String get commonUpToDate;

  /// No description provided for @commonToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get commonToday;

  /// No description provided for @commonNew.
  ///
  /// In pt, this message translates to:
  /// **'Novas'**
  String get commonNew;

  /// No description provided for @commonStudied.
  ///
  /// In pt, this message translates to:
  /// **'Estudadas'**
  String get commonStudied;

  /// No description provided for @commonOr.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get commonOr;

  /// No description provided for @commonTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonPlay.
  ///
  /// In pt, this message translates to:
  /// **'Reproduzir'**
  String get commonPlay;

  /// No description provided for @commonAudioError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao reproduzir áudio: {error}'**
  String commonAudioError(String error);

  /// No description provided for @commonCards.
  ///
  /// In pt, this message translates to:
  /// **'cards'**
  String get commonCards;

  /// No description provided for @commonScore.
  ///
  /// In pt, this message translates to:
  /// **'score'**
  String get commonScore;

  /// No description provided for @cefrA1.
  ///
  /// In pt, this message translates to:
  /// **'Iniciante'**
  String get cefrA1;

  /// No description provided for @cefrA2.
  ///
  /// In pt, this message translates to:
  /// **'Elementar'**
  String get cefrA2;

  /// No description provided for @cefrB1.
  ///
  /// In pt, this message translates to:
  /// **'Intermédio'**
  String get cefrB1;

  /// No description provided for @cefrB2.
  ///
  /// In pt, this message translates to:
  /// **'Intermédio Superior'**
  String get cefrB2;

  /// No description provided for @cefrC1.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get cefrC1;

  /// No description provided for @cefrC2.
  ///
  /// In pt, this message translates to:
  /// **'Proficiente'**
  String get cefrC2;

  /// No description provided for @offlineBanner.
  ///
  /// In pt, this message translates to:
  /// **'Modo offline — as alterações serão sincronizadas'**
  String get offlineBanner;

  /// No description provided for @aboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In pt, this message translates to:
  /// **'O FluentFlow é uma plataforma de estudo com repetição espaçada focada em listening e speaking.'**
  String get aboutDescription;

  /// No description provided for @aboutWebNote.
  ///
  /// In pt, this message translates to:
  /// **'Para adicionar, editar ou remover cards e decks, utiliza a versão Web do FluentFlow.'**
  String get aboutWebNote;

  /// No description provided for @aboutVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão {version}'**
  String aboutVersion(String version);

  /// No description provided for @homeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Listening, speaking e repetição espaçada (SM‑2) num fluxo contínuo de aprendizagem, com dashboards inteligentes e feedback real sobre o teu progresso.'**
  String get homeSubtitle;

  /// No description provided for @homeStartNow.
  ///
  /// In pt, this message translates to:
  /// **'Começar agora'**
  String get homeStartNow;

  /// No description provided for @homeAlreadyHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho conta'**
  String get homeAlreadyHaveAccount;

  /// No description provided for @homeSmartDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard Inteligente'**
  String get homeSmartDashboard;

  /// No description provided for @homeTrackDailyProgress.
  ///
  /// In pt, this message translates to:
  /// **'Acompanha o teu progresso diário'**
  String get homeTrackDailyProgress;

  /// No description provided for @homeAverageEf.
  ///
  /// In pt, this message translates to:
  /// **'EF médio'**
  String get homeAverageEf;

  /// No description provided for @homeProgress30Days.
  ///
  /// In pt, this message translates to:
  /// **'Progresso (últimos 30 dias)'**
  String get homeProgress30Days;

  /// No description provided for @homeSpeakingSession.
  ///
  /// In pt, this message translates to:
  /// **'Sessão de Speaking'**
  String get homeSpeakingSession;

  /// No description provided for @homeWhyDifferent.
  ///
  /// In pt, this message translates to:
  /// **'Porque o FluentFlow é diferente?'**
  String get homeWhyDifferent;

  /// No description provided for @homeFeatureMultimodal.
  ///
  /// In pt, this message translates to:
  /// **'Estudo multimodal'**
  String get homeFeatureMultimodal;

  /// No description provided for @homeFeatureMultimodalDesc.
  ///
  /// In pt, this message translates to:
  /// **'Listening e speaking no mesmo deck, com métricas separadas e histórico unificado.'**
  String get homeFeatureMultimodalDesc;

  /// No description provided for @homeFeatureSm2.
  ///
  /// In pt, this message translates to:
  /// **'SM‑2 real'**
  String get homeFeatureSm2;

  /// No description provided for @homeFeatureSm2Desc.
  ///
  /// In pt, this message translates to:
  /// **'Intervalos, EF e repetições calculados com o algoritmo original de repetição espaçada.'**
  String get homeFeatureSm2Desc;

  /// No description provided for @homeFeatureDashboards.
  ///
  /// In pt, this message translates to:
  /// **'Dashboards accionáveis'**
  String get homeFeatureDashboards;

  /// No description provided for @homeFeatureDashboardsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Atividade diária, distribuição de scores, novos/due/overdue e planeamento do dia.'**
  String get homeFeatureDashboardsDesc;

  /// No description provided for @homeFeaturePronunciation.
  ///
  /// In pt, this message translates to:
  /// **'Feedback de pronúncia'**
  String get homeFeaturePronunciation;

  /// No description provided for @homeFeaturePronunciationDesc.
  ///
  /// In pt, this message translates to:
  /// **'Similaridade de Levenshtein em tempo real — sabes exatamente onde melhorar.'**
  String get homeFeaturePronunciationDesc;

  /// No description provided for @homeHowItWorks.
  ///
  /// In pt, this message translates to:
  /// **'Como funciona?'**
  String get homeHowItWorks;

  /// No description provided for @homeStepCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Cria a tua conta.'**
  String get homeStepCreateAccount;

  /// No description provided for @homeStepCreateAccountDesc.
  ///
  /// In pt, this message translates to:
  /// **'Acesso seguro com JWT ou login social.'**
  String get homeStepCreateAccountDesc;

  /// No description provided for @homeStepCreateDeck.
  ///
  /// In pt, this message translates to:
  /// **'Cria um deck e faz upload de áudio.'**
  String get homeStepCreateDeck;

  /// No description provided for @homeStepCreateDeckDesc.
  ///
  /// In pt, this message translates to:
  /// **'O Whisper transcreve automaticamente.'**
  String get homeStepCreateDeckDesc;

  /// No description provided for @homeStepShortSessions.
  ///
  /// In pt, this message translates to:
  /// **'Estuda em sessões curtas.'**
  String get homeStepShortSessions;

  /// No description provided for @homeStepShortSessionsDesc.
  ///
  /// In pt, this message translates to:
  /// **'O sistema escolhe novos, due e overdue.'**
  String get homeStepShortSessionsDesc;

  /// No description provided for @homeStepTrackDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Acompanha o dashboard.'**
  String get homeStepTrackDashboard;

  /// No description provided for @homeStepTrackDashboardDesc.
  ///
  /// In pt, this message translates to:
  /// **'Ajusta o ritmo com base nos últimos 30 dias.'**
  String get homeStepTrackDashboardDesc;

  /// No description provided for @homeCtaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pronto para pôr o teu inglês em fluxo?'**
  String get homeCtaTitle;

  /// No description provided for @homeCtaSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cria a tua conta e começa a evoluir hoje mesmo.'**
  String get homeCtaSubtitle;

  /// No description provided for @homeCtaButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta gratuita'**
  String get homeCtaButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
