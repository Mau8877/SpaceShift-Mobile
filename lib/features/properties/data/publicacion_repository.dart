import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../domain/publicacion.dart';

part 'publicacion_repository.g.dart';

class PublicacionRepository {
  final Dio _dio;

  PublicacionRepository(this._dio);

  Future<Publicacion> createPublicacion(Publicacion publicacion) async {
    final response = await _dio.post(
      '/publicaciones',
      data: publicacion.toJson(),
    );
    return Publicacion.fromJson(response.data);
  }

  Future<List<Publicacion>> getPublicaciones() async {
    final response = await _dio.get('/publicaciones');
    return (response.data as List).map((p) => Publicacion.fromJson(p)).toList();
  }

  Future<Publicacion> getPublicacionById(String id) async {
    final response = await _dio.get('/publicaciones/$id');
    return Publicacion.fromJson(response.data);
  }

  Future<Publicacion> updatePublicacion(String id, Publicacion publicacion) async {
    final response = await _dio.put(
      '/publicaciones/$id',
      data: publicacion.toJson(),
    );
    return Publicacion.fromJson(response.data);
  }

  Future<void> deletePublicacion(String id) async {
    await _dio.delete('/publicaciones/$id');
  }
}

@riverpod
PublicacionRepository publicacionRepository(Ref ref) {
  return PublicacionRepository(ref.watch(dioProvider));
}
