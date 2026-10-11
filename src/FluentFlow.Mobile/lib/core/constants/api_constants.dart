class ApiConstants {
  ApiConstants._();

  /// URL da API. Por omissão aponta para produção; para usar a API local passar
  /// `--dart-define=API_BASE_URL=...` no `flutter run`:
  ///   - Emulador Android: http://10.0.2.2:5207  (10.0.2.2 = localhost do PC)
  ///   - Dispositivo físico: http://<IP-do-PC>:5207 (API com o perfil "mobile", 0.0.0.0)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-fluentflow.magnoweb.net',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
