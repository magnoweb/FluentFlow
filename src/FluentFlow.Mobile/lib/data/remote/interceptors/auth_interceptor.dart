import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/storage_keys.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  static const _skipPaths = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
  ];

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skip = _skipPaths.any((p) => options.path.contains(p));
    if (!skip) {
      final token = await _storage.read(key: StorageKeys.accessToken);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = await _storage.read(key: StorageKeys.refreshToken);
    if (refreshToken == null) return handler.next(err);

    try {
      final response = await _dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {}), // sem interceptor
      );

      final newAccess = response.data['accessToken'] as String;
      final newRefresh = response.data['refreshToken'] as String;

      await _storage.write(key: StorageKeys.accessToken, value: newAccess);
      await _storage.write(key: StorageKeys.refreshToken, value: newRefresh);

      // Repetir pedido original
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _storage.deleteAll();
      handler.next(err);
    }
  }
}
