import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/token_storage.dart';
import '../domain/register_request.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<void> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'correo': email, 'password': password},
    );

    final token = response.data['token'];
    await _storage.saveToken(token);
  }

  Future<void> register(RegisterRequest request) async {
    final response = await _dio.post(
      '/auth/registro',
      data: request.toJson(),
    );

    final token = response.data['token'];
    await _storage.saveToken(token);
  }

  Future<String> solicitarRecuperacion(String correo) async {
    final response = await _dio.post(
      '/auth/recuperar-password',
      data: {'correo': correo},
    );
    return response.data['mensaje'] ?? 'Código enviado';
  }

  Future<String> validarCodigo(String correo, String codigo) async {
    final response = await _dio.post(
      '/auth/validar-codigo',
      data: {'correo': correo, 'codigo': codigo},
    );
    return response.data['mensaje'] ?? 'Código válido';
  }

  Future<String> cambiarPassword(String correo, String codigo, String nuevaPassword) async {
    final response = await _dio.post(
      '/auth/cambiar-password',
      data: {'correo': correo, 'codigo': codigo, 'nuevaPassword': nuevaPassword},
    );
    return response.data['mensaje'] ?? 'Contraseña actualizada';
  }

  Future<void> logout() async {
    await _storage.clearToken();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(tokenStorageProvider),
  );
}
