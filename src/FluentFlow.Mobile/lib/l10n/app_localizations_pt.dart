// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'FluentFlow';

  @override
  String get appSubTitle => 'Fluência que flui com o teu ritmo';

  @override
  String get socialCallbackAuthenticating => 'A autenticar...';

  @override
  String get socialCallbackError => 'Erro na autenticação';

  @override
  String get socialCallbackRedirecting => 'A redirecionar para o login...';

  @override
  String get socialCallbackTokensNotReceived => 'Tokens não recebidos.';

  @override
  String socialCallbackError2(String error) {
    return 'Erro no callback: $error';
  }

  @override
  String get authOr => 'ou';

  @override
  String get authContinueWithMicrosoft => 'Continuar com Microsoft';

  @override
  String authSocialLoginError(String error) {
    return 'Erro no login social: $error';
  }

  @override
  String get navHome => 'Início';

  @override
  String get navDecks => 'Os meus Decks';

  @override
  String get navSessions => 'Sessões';

  @override
  String get authLogin => 'Iniciar sessão';

  @override
  String get authLogout => 'Terminar sessão';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authName => 'Nome completo';

  @override
  String get authWelcomeBack => 'Bem-vindo de volta';

  @override
  String get authLoginSubtitle => 'Inicia sessão para continuar';

  @override
  String get authContinueGoogle => 'Continuar com Google';

  @override
  String get authContinueMicrosoft => 'Continuar com Microsoft';

  @override
  String get authContinueGitHub => 'Continuar com GitHub';

  @override
  String get authInvalidCredentials => 'Email ou password incorrectos.';

  @override
  String get authSignIn => 'Iniciar sessão';

  @override
  String authSocialError(String error) {
    return 'Erro no login social: $error';
  }

  @override
  String get decksTitle => 'Os meus Decks';

  @override
  String get decksNew => 'Novo Deck';

  @override
  String get decksNoDecks => 'Ainda não tens decks.';

  @override
  String decksTotalCards(int count) {
    return '$count cards';
  }

  @override
  String decksReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisões',
      one: '$count revisão',
    );
    return '$_temp0';
  }

  @override
  String decksNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novas',
      one: '$count nova',
    );
    return '$_temp0';
  }

  @override
  String get decksDueToday => 'Para rever hoje';

  @override
  String get decksNewToday => 'Novas hoje';

  @override
  String get decksStudiedToday => 'Estudadas hoje';

  @override
  String get decksDetailTitle => 'Detalhe do Deck';

  @override
  String get decksNotFound => 'Deck não encontrado.';

  @override
  String get decksNoCards => 'Sem cards neste deck.';

  @override
  String get studyPlan => 'Plano de Estudo';

  @override
  String get studyMode => 'Modo de estudo';

  @override
  String get studyListening => 'Listening';

  @override
  String get studySpeaking => 'Speaking';

  @override
  String get studyStarting => 'A iniciar...';

  @override
  String get studyStartError => 'Erro ao iniciar sessão.';

  @override
  String get studyStart => 'Iniciar sessão';

  @override
  String get studyEnd => 'Encerrar sessão';

  @override
  String get studyEndConfirm => 'Tem a certeza que quer encerrar a sessão?';

  @override
  String get studyHowDidItGo => 'Como correu?';

  @override
  String get studyTapToReveal => 'Clique para ver a resposta';

  @override
  String get studyScore0 => 'Nada (0)';

  @override
  String get studyScore1 => 'Errei (1)';

  @override
  String get studyScore2 => 'Difícil (2)';

  @override
  String get studyScore3 => 'Ok (3)';

  @override
  String get studyScore4 => 'Bem (4)';

  @override
  String get studyScore5 => 'Fácil (5)';

  @override
  String get studyComplete => 'Sessão concluída!';

  @override
  String get studyGoHome => 'Ir para o início';

  @override
  String get studyGoDecks => 'Ver os meus decks';

  @override
  String get studyReviewedCards => 'Cards revistos';

  @override
  String get studyAverageScore => 'Score médio';

  @override
  String studyEndSummary(int reviewed, int total) {
    return '$reviewed de $total cards revistos serão guardados.';
  }

  @override
  String get studyRecord => 'Gravar';

  @override
  String get studyStop => 'Parar';

  @override
  String get studyRecording => 'A gravar...';

  @override
  String get studyTranscribing => 'A transcrever...';

  @override
  String get studyListeningState => 'A ouvir...';

  @override
  String get studyNativeTranscription => 'Transcrição nativa (offline)';

  @override
  String get studyApiTranscription => 'Transcrição via API';

  @override
  String get studyYouSaid => 'Você disse:';

  @override
  String get studyTryAgain => 'Tentar novamente';

  @override
  String get studyNoCards => 'Não há cards para rever hoje neste modo.';

  @override
  String get studyOfflineNative => 'Offline — transcrição nativa activa';

  @override
  String get studyOfflineReviews =>
      'Modo offline — revisões serão sincronizadas';

  @override
  String get studyListeningEmoji => '🎧 Listening';

  @override
  String get studySpeakingEmoji => '🗣️ Speaking';

  @override
  String get sessionsTitle => 'Sessões de Estudo';

  @override
  String get sessionsAll => 'Todas';

  @override
  String get sessionsDuration => 'Duração';

  @override
  String get sessionsNoSessions => 'Nenhuma sessão encontrada.';

  @override
  String get sessionsDetailTitle => 'Detalhe da Sessão';

  @override
  String get sessionsNotFound => 'Sessão não encontrada.';

  @override
  String get sessionsScoreDistribution => 'Distribuição de scores';

  @override
  String sessionsReviewedCount(int count) {
    return 'Cards revistos ($count)';
  }

  @override
  String sessionsIntervalChange(int prev, int next) {
    return 'Intervalo: ${prev}d → ${next}d';
  }

  @override
  String sessionsReviewedCards(int reviewed, int total) {
    return 'Cards revistos $reviewed de $total';
  }

  @override
  String get profileTitle => 'O meu perfil';

  @override
  String get profileName => 'Nome completo';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileChangePassword => 'Alterar password';

  @override
  String get profileCurrentPassword => 'Password actual';

  @override
  String get profileNewPassword => 'Nova password';

  @override
  String get profileSave => 'Guardar alterações';

  @override
  String get profileRemovePhoto => 'Remover foto';

  @override
  String get profileAvatarTooBig => 'Imagem demasiado grande. Máximo 200 KB.';

  @override
  String get commonHello => 'Olá';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonLoading => 'A carregar...';

  @override
  String get commonOk => 'Ok';

  @override
  String get commonError => 'Ocorreu um erro. Tente novamente.';

  @override
  String get commonStudy => 'Estudar';

  @override
  String get commonDetails => 'Ver detalhes';

  @override
  String get commonLanguage => 'Idioma';

  @override
  String get commonUpToDate => 'Em dia';

  @override
  String get commonToday => 'Hoje';

  @override
  String get commonNew => 'Novas';

  @override
  String get commonStudied => 'Estudadas';

  @override
  String get commonOr => 'ou';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonPlay => 'Reproduzir';

  @override
  String commonAudioError(String error) {
    return 'Erro ao reproduzir áudio: $error';
  }

  @override
  String get commonCards => 'cards';

  @override
  String get commonScore => 'score';

  @override
  String get cefrA1 => 'Iniciante';

  @override
  String get cefrA2 => 'Elementar';

  @override
  String get cefrB1 => 'Intermédio';

  @override
  String get cefrB2 => 'Intermédio Superior';

  @override
  String get cefrC1 => 'Avançado';

  @override
  String get cefrC2 => 'Proficiente';

  @override
  String get offlineBanner =>
      'Modo offline — as alterações serão sincronizadas';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutDescription =>
      'O FluentFlow é uma plataforma de estudo com repetição espaçada focada em listening e speaking.';

  @override
  String get aboutWebNote =>
      'Para adicionar, editar ou remover cards e decks, utiliza a versão Web do FluentFlow.';

  @override
  String aboutVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get homeSubtitle =>
      'Listening, speaking e repetição espaçada (SM‑2) num fluxo contínuo de aprendizagem, com dashboards inteligentes e feedback real sobre o teu progresso.';

  @override
  String get homeStartNow => 'Começar agora';

  @override
  String get homeAlreadyHaveAccount => 'Já tenho conta';

  @override
  String get homeSmartDashboard => 'Dashboard Inteligente';

  @override
  String get homeTrackDailyProgress => 'Acompanha o teu progresso diário';

  @override
  String get homeAverageEf => 'EF médio';

  @override
  String get homeProgress30Days => 'Progresso (últimos 30 dias)';

  @override
  String get homeSpeakingSession => 'Sessão de Speaking';

  @override
  String get homeWhyDifferent => 'Porque o FluentFlow é diferente?';

  @override
  String get homeFeatureMultimodal => 'Estudo multimodal';

  @override
  String get homeFeatureMultimodalDesc =>
      'Listening e speaking no mesmo deck, com métricas separadas e histórico unificado.';

  @override
  String get homeFeatureSm2 => 'SM‑2 real';

  @override
  String get homeFeatureSm2Desc =>
      'Intervalos, EF e repetições calculados com o algoritmo original de repetição espaçada.';

  @override
  String get homeFeatureDashboards => 'Dashboards accionáveis';

  @override
  String get homeFeatureDashboardsDesc =>
      'Atividade diária, distribuição de scores, novos/due/overdue e planeamento do dia.';

  @override
  String get homeFeaturePronunciation => 'Feedback de pronúncia';

  @override
  String get homeFeaturePronunciationDesc =>
      'Similaridade de Levenshtein em tempo real — sabes exatamente onde melhorar.';

  @override
  String get homeHowItWorks => 'Como funciona?';

  @override
  String get homeStepCreateAccount => 'Cria a tua conta.';

  @override
  String get homeStepCreateAccountDesc =>
      'Acesso seguro com JWT ou login social.';

  @override
  String get homeStepCreateDeck => 'Cria um deck e faz upload de áudio.';

  @override
  String get homeStepCreateDeckDesc => 'O Whisper transcreve automaticamente.';

  @override
  String get homeStepShortSessions => 'Estuda em sessões curtas.';

  @override
  String get homeStepShortSessionsDesc =>
      'O sistema escolhe novos, due e overdue.';

  @override
  String get homeStepTrackDashboard => 'Acompanha o dashboard.';

  @override
  String get homeStepTrackDashboardDesc =>
      'Ajusta o ritmo com base nos últimos 30 dias.';

  @override
  String get homeCtaTitle => 'Pronto para pôr o teu inglês em fluxo?';

  @override
  String get homeCtaSubtitle =>
      'Cria a tua conta e começa a evoluir hoje mesmo.';

  @override
  String get homeCtaButton => 'Criar conta gratuita';

  @override
  String get navPodcasts => 'Podcasts';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String studyRepeatCount(int current, int total) {
    return 'Repetição $current/$total';
  }

  @override
  String get studySpeed => 'Velocidade';

  @override
  String get podcastsAudioError => 'Não foi possível reproduzir o áudio.';

  @override
  String get podcastsAutoNext => 'Passar ao próximo episódio automaticamente';

  @override
  String get podcastsContinue => 'Continuar';

  @override
  String get podcastsContinueListening => 'Continuar de onde parou';

  @override
  String get podcastsEmpty =>
      'Ainda não tem episódios. Envie os ficheiros do PodcastGenerator no site (Podcasts → Enviar episódios).';

  @override
  String get podcastsEpisodeFinished => 'Episódio concluído!';

  @override
  String get podcastsFavorite => 'Favorito';

  @override
  String get podcastsFilterAll => 'Todos';

  @override
  String get podcastsFilterCompleted => 'Ouvidos';

  @override
  String get podcastsFilterFavorites => 'Favoritos';

  @override
  String get podcastsFilterInProgress => 'Em curso';

  @override
  String get podcastsFilterNotStarted => 'Por ouvir';

  @override
  String get podcastsFollowText => 'Acompanhar o texto';

  @override
  String get podcastsGeneral => 'Geral';

  @override
  String podcastsGroupProgress(int completed, int total) {
    return '$completed de $total ouvidos';
  }

  @override
  String get podcastsHomeSubtitle =>
      'Diálogos do dia-a-dia com texto sincronizado';

  @override
  String get podcastsListen => 'Ouvir';

  @override
  String get podcastsListenAgain => 'Ouvir novamente';

  @override
  String get podcastsMarkListened => 'Marcar como ouvido';

  @override
  String get podcastsMarkUnlistened => 'Marcar como não ouvido';

  @override
  String get podcastsMarkedListened => 'Episódio marcado como ouvido.';

  @override
  String get podcastsMarkedUnlistened => 'Episódio marcado como não ouvido.';

  @override
  String get podcastsNextEpisode => 'Próximo episódio';

  @override
  String podcastsNextIn(String title, int seconds) {
    return 'A seguir: $title em $seconds s';
  }

  @override
  String get podcastsNextLine => 'Próxima frase';

  @override
  String get podcastsNoMatches => 'Nenhum episódio corresponde aos filtros.';

  @override
  String get podcastsPlayNow => 'Ouvir já';

  @override
  String get podcastsPreviousEpisode => 'Episódio anterior';

  @override
  String get podcastsPreviousLine => 'Frase anterior';

  @override
  String get podcastsRepeatLine => 'Repetir a frase actual';

  @override
  String get podcastsRestart => 'Recomeçar';

  @override
  String podcastsResumePrompt(String position) {
    return 'Parou em $position. Quer continuar ou recomeçar?';
  }

  @override
  String podcastsSeason(int season) {
    return 'Temporada $season';
  }

  @override
  String get podcastsSectionDialogue => 'Diálogo';

  @override
  String get podcastsSectionIntro => 'Introdução';

  @override
  String get podcastsSectionOutro => 'Encerramento';

  @override
  String get podcastsSectionReview => 'Revisão';

  @override
  String get podcastsSettings => 'Definições do player';

  @override
  String get podcastsShowTranslation => 'Mostrar tradução';

  @override
  String podcastsSlowVersion(String tempo) {
    return 'Versão lenta ($tempo)';
  }

  @override
  String get podcastsSpeed => 'Velocidade';

  @override
  String get podcastsStatsCompleted => 'Episódios ouvidos';

  @override
  String get podcastsStatsInProgress => 'Em curso';

  @override
  String get podcastsStatsMinutes => 'Minutos ouvidos';

  @override
  String podcastsStoppedAt(String position, String duration) {
    return 'Parou em $position de $duration';
  }

  @override
  String get podcastsSubtitle =>
      'Ouça diálogos do dia-a-dia e acompanhe o texto frase a frase.';

  @override
  String podcastsTimesListened(int count) {
    return 'Ouvido $count×';
  }

  @override
  String get podcastsTitle => 'Podcasts';

  @override
  String get podcastsUpNext => 'A seguir';

  @override
  String get podcastsDelete => 'Eliminar episódio';

  @override
  String podcastsDeleteConfirm(String title) {
    return 'Eliminar o episódio \"$title\"? Os áudios e o progresso serão apagados.';
  }

  @override
  String get podcastsDeleted => 'Episódio eliminado.';
}
