class ApiConstants {
  ApiConstants._();

  // Alterar para o IP da máquina de desenvolvimento
  // (localhost não funciona em dispositivo físico)
  // static const String baseUrl = 'https://10.0.2.2:7001'; // Android emulator
  static const String baseUrl = 'http://192.168.1.121:5207'; // dispositivo físico

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}