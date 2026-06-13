// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FluentFlow';

  @override
  String get appSubTitle => 'Fluidez que fluye con tu ritmo';

  @override
  String get socialCallbackAuthenticating => 'Autenticando...';

  @override
  String get socialCallbackError => 'Error de autenticación';

  @override
  String get socialCallbackRedirecting => 'Redirigiendo al inicio de sesión...';

  @override
  String get socialCallbackTokensNotReceived => 'Tokens no recibidos.';

  @override
  String socialCallbackError2(String error) {
    return 'Error en el callback: $error';
  }

  @override
  String get authOr => 'o';

  @override
  String get authContinueWithMicrosoft => 'Continuar con Microsoft';

  @override
  String authSocialLoginError(String error) {
    return 'Error en inicio de sesión social: $error';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navDecks => 'Mis Mazos';

  @override
  String get navSessions => 'Sesiones';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authLogout => 'Cerrar sesión';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authName => 'Nombre completo';

  @override
  String get authWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get authLoginSubtitle => 'Inicia sesión para continuar';

  @override
  String get authContinueGoogle => 'Continuar con Google';

  @override
  String get authContinueMicrosoft => 'Continuar con Microsoft';

  @override
  String get authContinueGitHub => 'Continuar con GitHub';

  @override
  String get authInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String authSocialError(String error) {
    return 'Error en el inicio de sesión social: $error';
  }

  @override
  String get decksTitle => 'Mis Mazos';

  @override
  String get decksNew => 'Nuevo Mazo';

  @override
  String get decksNoDecks => 'Aún no tienes mazos.';

  @override
  String decksTotalCards(int count) {
    return '$count tarjetas';
  }

  @override
  String decksReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisiones',
      one: '$count revisión',
    );
    return '$_temp0';
  }

  @override
  String decksNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuevas',
      one: '$count nueva',
    );
    return '$_temp0';
  }

  @override
  String get decksDueToday => 'Para revisar hoy';

  @override
  String get decksNewToday => 'Nuevas hoy';

  @override
  String get decksStudiedToday => 'Estudiadas hoy';

  @override
  String get decksDetailTitle => 'Detalle del Mazo';

  @override
  String get decksNotFound => 'Mazo no encontrado.';

  @override
  String get decksNoCards => 'Sin tarjetas en este mazo.';

  @override
  String get studyPlan => 'Plan de Estudio';

  @override
  String get studyMode => 'Modo de estudio';

  @override
  String get studyListening => 'Escucha';

  @override
  String get studySpeaking => 'Habla';

  @override
  String get studyStarting => 'Iniciando...';

  @override
  String get studyStartError => 'Error al iniciar la sesión.';

  @override
  String get studyStart => 'Iniciar sesión';

  @override
  String get studyEnd => 'Terminar sesión';

  @override
  String get studyEndConfirm =>
      '¿Estás seguro de que quieres terminar la sesión?';

  @override
  String get studyHowDidItGo => '¿Cómo te fue?';

  @override
  String get studyTapToReveal => 'Toca para ver la respuesta';

  @override
  String get studyScore0 => 'Nada (0)';

  @override
  String get studyScore1 => 'Fallé (1)';

  @override
  String get studyScore2 => 'Difícil (2)';

  @override
  String get studyScore3 => 'Ok (3)';

  @override
  String get studyScore4 => 'Bien (4)';

  @override
  String get studyScore5 => 'Fácil (5)';

  @override
  String get studyComplete => '¡Sesión completada!';

  @override
  String get studyGoHome => 'Ir al inicio';

  @override
  String get studyGoDecks => 'Ver mis mazos';

  @override
  String get studyReviewedCards => 'Tarjetas revisadas';

  @override
  String get studyAverageScore => 'Puntuación media';

  @override
  String studyEndSummary(int reviewed, int total) {
    return '$reviewed de $total tarjetas revisadas serán guardadas.';
  }

  @override
  String get studyRecord => 'Grabar';

  @override
  String get studyStop => 'Parar';

  @override
  String get studyRecording => 'Grabando...';

  @override
  String get studyTranscribing => 'Transcribiendo...';

  @override
  String get studyListeningState => 'Escuchando...';

  @override
  String get studyNativeTranscription => 'Transcripción nativa (offline)';

  @override
  String get studyApiTranscription => 'Transcripción vía API';

  @override
  String get studyYouSaid => 'Dijiste:';

  @override
  String get studyTryAgain => 'Intentar de nuevo';

  @override
  String get studyNoCards => 'No hay tarjetas para revisar hoy en este modo.';

  @override
  String get studyOfflineNative => 'Sin conexión — transcripción nativa activa';

  @override
  String get studyOfflineReviews =>
      'Modo sin conexión — las revisiones se sincronizarán';

  @override
  String get studyListeningEmoji => '🎧 Escucha';

  @override
  String get studySpeakingEmoji => '🗣️ Habla';

  @override
  String get sessionsTitle => 'Sesiones de Estudio';

  @override
  String get sessionsAll => 'Todas';

  @override
  String get sessionsDuration => 'Duración';

  @override
  String get sessionsNoSessions => 'No se encontraron sesiones.';

  @override
  String get sessionsDetailTitle => 'Detalle de Sesión';

  @override
  String get sessionsNotFound => 'Sesión no encontrada.';

  @override
  String get sessionsScoreDistribution => 'Distribución de puntuaciones';

  @override
  String sessionsReviewedCount(int count) {
    return 'Tarjetas revisadas ($count)';
  }

  @override
  String sessionsIntervalChange(int prev, int next) {
    return 'Intervalo: ${prev}d → ${next}d';
  }

  @override
  String sessionsReviewedCards(int reviewed, int total) {
    return 'Tarjetas revisadas $reviewed de $total';
  }

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profileName => 'Nombre completo';

  @override
  String get profileEmail => 'Correo electrónico';

  @override
  String get profileChangePassword => 'Cambiar contraseña';

  @override
  String get profileCurrentPassword => 'Contraseña actual';

  @override
  String get profileNewPassword => 'Nueva contraseña';

  @override
  String get profileSave => 'Guardar cambios';

  @override
  String get profileRemovePhoto => 'Eliminar foto';

  @override
  String get profileAvatarTooBig => 'Imagen demasiado grande. Máximo 200 KB.';

  @override
  String get commonHello => 'Hola';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonBack => 'Volver';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonOk => 'Ok';

  @override
  String get commonError => 'Ocurrió un error. Inténtalo de nuevo.';

  @override
  String get commonStudy => 'Estudiar';

  @override
  String get commonDetails => 'Ver detalles';

  @override
  String get commonLanguage => 'Idioma';

  @override
  String get commonUpToDate => 'Al día';

  @override
  String get commonToday => 'Hoy';

  @override
  String get commonNew => 'Nuevas';

  @override
  String get commonStudied => 'Estudiadas';

  @override
  String get commonOr => 'o';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonPlay => 'Reproducir';

  @override
  String commonAudioError(String error) {
    return 'Error al reproducir audio: $error';
  }

  @override
  String get commonCards => 'tarjetas';

  @override
  String get commonScore => 'puntuación';

  @override
  String get cefrA1 => 'Principiante';

  @override
  String get cefrA2 => 'Elemental';

  @override
  String get cefrB1 => 'Intermedio';

  @override
  String get cefrB2 => 'Intermedio Alto';

  @override
  String get cefrC1 => 'Avanzado';

  @override
  String get cefrC2 => 'Competente';

  @override
  String get offlineBanner =>
      'Modo sin conexión — los cambios se sincronizarán';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutDescription =>
      'FluentFlow es una plataforma de estudio con repetición espaciada enfocada en listening y speaking.';

  @override
  String get aboutWebNote =>
      'Para añadir, editar o eliminar tarjetas y mazos, utiliza la versión Web de FluentFlow.';

  @override
  String aboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get homeSubtitle =>
      'Listening, speaking y repetición espaciada (SM‑2) en un flujo continuo de aprendizaje, con paneles inteligentes y retroalimentación real sobre tu progreso.';

  @override
  String get homeStartNow => 'Comenzar ahora';

  @override
  String get homeAlreadyHaveAccount => 'Ya tengo cuenta';

  @override
  String get homeSmartDashboard => 'Panel Inteligente';

  @override
  String get homeTrackDailyProgress => 'Sigue tu progreso diario';

  @override
  String get homeAverageEf => 'EF medio';

  @override
  String get homeProgress30Days => 'Progreso (últimos 30 días)';

  @override
  String get homeSpeakingSession => 'Sesión de Speaking';

  @override
  String get homeWhyDifferent => '¿Por qué FluentFlow es diferente?';

  @override
  String get homeFeatureMultimodal => 'Estudio multimodal';

  @override
  String get homeFeatureMultimodalDesc =>
      'Listening y speaking en el mismo mazo, con métricas separadas e historial unificado.';

  @override
  String get homeFeatureSm2 => 'SM‑2 real';

  @override
  String get homeFeatureSm2Desc =>
      'Intervalos, EF y repeticiones calculados con el algoritmo original de repetición espaciada.';

  @override
  String get homeFeatureDashboards => 'Paneles accionables';

  @override
  String get homeFeatureDashboardsDesc =>
      'Actividad diaria, distribución de puntuaciones, nuevas/due/overdue y planificación del día.';

  @override
  String get homeFeaturePronunciation => 'Feedback de pronunciación';

  @override
  String get homeFeaturePronunciationDesc =>
      'Similaridad de Levenshtein en tiempo real — sabes exactamente dónde mejorar.';

  @override
  String get homeHowItWorks => '¿Cómo funciona?';

  @override
  String get homeStepCreateAccount => 'Crea tu cuenta.';

  @override
  String get homeStepCreateAccountDesc =>
      'Acceso seguro con JWT o inicio de sesión social.';

  @override
  String get homeStepCreateDeck => 'Crea un mazo y sube audio.';

  @override
  String get homeStepCreateDeckDesc => 'Whisper transcribe automáticamente.';

  @override
  String get homeStepShortSessions => 'Estudia en sesiones cortas.';

  @override
  String get homeStepShortSessionsDesc =>
      'El sistema selecciona nuevas, due y overdue.';

  @override
  String get homeStepTrackDashboard => 'Sigue el panel.';

  @override
  String get homeStepTrackDashboardDesc =>
      'Ajusta tu ritmo según los últimos 30 días.';

  @override
  String get homeCtaTitle => '¿Listo para poner tu inglés en flujo?';

  @override
  String get homeCtaSubtitle => 'Crea tu cuenta y empieza a mejorar hoy mismo.';

  @override
  String get homeCtaButton => 'Crear cuenta gratuita';
}
