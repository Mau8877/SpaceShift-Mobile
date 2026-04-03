import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/token_storage.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<void> login(String email, String password) async {
    // Nota: Usamos una ruta relativa porque Dio ya tiene la baseUrl
    final response = await _dio.post(
      '/auth/login',
      data: {'correo': email, 'password': password},
    );

    // Guardamos el token que devuelve tu Spring Boot
    final token = response.data['token'];
    await _storage.saveToken(token);
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(tokenStorageProvider),
  );
}
