import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/jwt_utils.dart';
import '../../../core/network/token_storage.dart';
import '../domain/perfil_model.dart';

part 'perfil_repository.g.dart';

class PerfilRepository {
  final Dio _dio;

  PerfilRepository(this._dio);

  Future<String> _getUserId() async {
    final tokenStorage = TokenStorage();
    final token = await tokenStorage.getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación');
    }
    final userId = JwtUtils.extractUserId(token);
    if (userId == null) {
      throw Exception('No se pudo obtener el ID del usuario');
    }
    return userId;
  }

  Future<Perfil> obtenerMiPerfil() async {
    final response = await _dio.get('/perfil/me');
    return Perfil.fromJson(response.data);
  }

  Future<Perfil> obtenerPerfilPorUsuario(String idUsuario) async {
    final response = await _dio.get('/perfil/usuario/$idUsuario');
    return Perfil.fromJson(response.data);
  }

  Future<Perfil> actualizarMiPerfil(PerfilPatchRequestFull request) async {
    final userId = await _getUserId();
    final response = await _dio.patch(
      '/perfil/usuario/$userId',
      data: request.toJson(),
    );
    return Perfil.fromJson(response.data);
  }
}

@riverpod
PerfilRepository perfilRepository(Ref ref) {
  return PerfilRepository(ref.watch(dioProvider));
}