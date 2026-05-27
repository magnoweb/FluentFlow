import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;

  RetryInterceptor(this._dio, {this.maxRetries = 2});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retries = (extra['retryCount'] as int?) ?? 0;

    final isRetryable =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (isRetryable && retries < maxRetries) {
      await Future.delayed(Duration(seconds: (retries + 1) * 2)); // backoff

      err.requestOptions.extra['retryCount'] = retries + 1;
      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}
