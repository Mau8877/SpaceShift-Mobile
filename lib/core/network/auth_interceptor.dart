import 'package:dio/dio.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio
  _dio; // Volvemos a necesitar a Dio para hacer la petición de refresh
  final TokenStorage _storage;
  final Function() onLogoutRequired;

  AuthInterceptor(this._dio, this._storage, {required this.onLogoutRequired});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();

    if (token != null && !options.path.contains('/auth/login')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Si Spring Boot dice 401 (token expirado)
    if (err.response?.statusCode == 401) {
      if (err.requestOptions.path.contains('/auth/refresh')) {
        await _storage.clearToken();
        onLogoutRequired();
        return handler.next(err);
      }

      final oldToken = await _storage.getToken();

      if (oldToken != null) {
        try {
          final refreshResponse = await _dio.post(
            '/auth/refresh',
            data: {'token': oldToken},
          );

          final newToken = refreshResponse.data['newToken'];

          await _storage.saveToken(newToken);

          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          final cloneReq = await _dio.fetch(options);
          return handler.resolve(cloneReq);
        } catch (e) {
          await _storage.clearToken();
          onLogoutRequired();
          return handler.next(err);
        }
      } else {
        onLogoutRequired();
      }
    }

    return handler.next(err);
  }
}
