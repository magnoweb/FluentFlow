import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/storage_keys.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage) {
    _dio =
        Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: ApiConstants.connectTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              headers: {'Content-Type': 'application/json'},
              // Aceitar certificados self-signed em desenvolvimento
              validateStatus: (status) =>
                  status != null && (status < 400 || status == 404),
            ),
          )
          ..interceptors.add(_AuthInterceptor(_storage, this))
          ..interceptors.add(
            PrettyDioLogger(
              requestHeader: false,
              requestBody: true,
              responseBody: true,
              responseHeader: false,
              compact: true,
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                options.headers['X-Client-Platform'] = 'Mobile';
                return handler.next(options);
              },
            ),
          );
  }

  // Adicionar ao api_client.dart

  Future<Map<String, dynamic>> getDashboard(String deckId) async {
    final r = await _dio.get('/api/study/dashboard/$deckId');
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCards(
    String deckId, {
    int page = 1,
    int pageSize = 100,
  }) async {
    final r = await _dio.get(
      '/api/decks/$deckId/cards',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return r.data as Map<String, dynamic>;
  }

  // ── Auth ───────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final r = await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final r = await _dio.post(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<void> logout(String refreshToken) =>
      _dio.post('/api/auth/logout', data: {'refreshToken': refreshToken});

  // ── Social Login ───────────────────────────────────────────────────────────
  // Retorna a URL de redirect para o provider
  String getSocialLoginUrl(String provider) =>
      '${ApiConstants.baseUrl}/api/auth/login/$provider'
      '?returnUrl=fluentflow://auth/callback';

  // Após o callback, trocar o token
  Future<Map<String, dynamic>> handleSocialCallback(
    String provider,
    String code,
  ) async {
    final r = await _dio.get(
      '/api/auth/callback/$provider',
      queryParameters: {'code': code},
    );
    return r.data as Map<String, dynamic>;
  }

  // ── Perfil ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProfile() async {
    final r = await _dio.get('/api/auth/profile');
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
    String? profileImageBase64,
  }) async {
    final r = await _dio.put(
      '/api/auth/profile',
      data: {
        'name': name,
        'email': email,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'profileImageBase64': profileImageBase64,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  // ── Decks ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDecks({
    int page = 1,
    int pageSize = 50,
  }) async {
    final r = await _dio.get(
      '/api/decks',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return r.data as Map<String, dynamic>;
  }

  // ── Study ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getStudyPlan(String deckId, String mode) async {
    final modeInt = mode == 'Listening' ? 0 : 1;
    final r = await _dio.get(
      '/api/study/plan/$deckId',
      queryParameters: {'mode': modeInt},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> startSession(String deckId, String mode) async {
    final modeInt = mode == 'Listening' ? 0 : 1;
    final r = await _dio.post(
      '/api/study/start',
      data: {'deckId': deckId, 'mode': modeInt},
    );
    return r.data as Map<String, dynamic>;
  }

  Future<void> submitReview({
    required String sessionId,
    required String cardId,
    required int score,
    double? similarityScore,
    String? transcribedText,
  }) => _dio.post(
    '/api/study/review',
    data: {
      'sessionId': sessionId,
      'cardId': cardId,
      'score': score,
      'similarityScore': similarityScore,
      'transcribedText': transcribedText,
    },
  );

  Future<Map<String, dynamic>> endSession(String sessionId) async {
    final r = await _dio.post('/api/study/end/$sessionId');
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSessions({
    String? deckId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final r = await _dio.get(
      '/api/study/sessions',
      queryParameters: {
        if (deckId != null) 'deckId': deckId,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSessionDetail(String sessionId) async {
    final r = await _dio.get('/api/study/sessions/$sessionId');
    return r.data as Map<String, dynamic>;
  }

  // ── Transcrição ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> transcribeAudio({
    required String audioBase64,
    required String extension,
    required String originalText,
    required String language,
  }) async {
    final r = await _dio.post(
      '/api/study/transcribe',
      data: {
        'audioBase64': audioBase64,
        'extension': extension,
        'originalText': originalText,
        'language': language,
      },
    );
    return r.data as Map<String, dynamic>;
  }
}

// ── Auth Interceptor — injeta Bearer e faz refresh automático ─────────────────
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final ApiClient _client;

  _AuthInterceptor(this._storage, this._client);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Não injectar token nos endpoints de auth
    final skipPaths = [
      '/api/auth/login',
      '/api/auth/register',
      '/api/auth/refresh',
    ];
    if (skipPaths.any((p) => options.path.contains(p))) {
      return handler.next(options);
    }

    final token = await _storage.read(key: StorageKeys.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 1. Verificamos se é 401 e se NÃO é uma tentativa de refresh que falhou (evita loop)
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/api/auth/refresh')) {
      final refreshToken = await _storage.read(key: StorageKeys.refreshToken);

      if (refreshToken != null) {
        try {
          // 2. Tentar o refresh
          final result = await _client.refresh(refreshToken);
          final newAccess = result['accessToken'] as String;
          final newRefresh = result['refreshToken'] as String;

          await _storage.write(key: StorageKeys.accessToken, value: newAccess);
          await _storage.write(
            key: StorageKeys.refreshToken,
            value: newRefresh,
          );

          // 3. REPETIR a requisição original usando a mesma instância _dio
          // para garantir que baseUrl e headers estejam corretos.
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';

          final response = await _client._dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {
          // Se o refresh falhar (ex: refresh token expirado), desloga
          await _storage.deleteAll();
          // Opcional: Redirecionar para login aqui via Navigator ou Stream
        }
      }
    }
    return handler.next(err);
  }
}
