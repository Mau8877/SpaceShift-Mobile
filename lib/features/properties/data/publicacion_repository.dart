import 'dart:io';
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

  Future<List<Publicacion>> getPublicaciones({
    String? transactionType,
    String? location,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (transactionType != null) queryParams['tipoTransaccion'] = transactionType;
    if (location != null) queryParams['ubicacion'] = location;
    if (propertyType != null) queryParams['tipoInmueble'] = propertyType;
    if (minPrice != null) queryParams['minPrecio'] = minPrice;
    if (maxPrice != null) queryParams['maxPrecio'] = maxPrice;

    final response = await _dio.get(
      '/publicaciones',
      queryParameters: queryParams,
    );

    return (response.data as List)
        .map((p) => Publicacion.fromJson(p))
        .toList();
  }

  Future<List<String>> uploadImages(List<File> files) async {
    final formData = FormData();
    for (var file in files) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(file.path),
      ));
    }

    final response = await _dio.post(
      '/upload/imagenes',
      data: formData,
    );
    
    return List<String>.from(response.data);
  }

  Future<List<Publicacion>> getMisPublicaciones() async {
    final response = await _dio.get('/publicaciones/mis-publicaciones');
    return (response.data as List).map((p) => Publicacion.fromJson(p)).toList();
  }

  Future<List<Publicacion>> getMisFavoritos() async {
    final response = await _dio.get('/publicaciones/mis-favoritos');
    return (response.data as List).map((p) => Publicacion.fromJson(p)).toList();
  }

  Future<void> alternarFavorito(String id) async {
    await _dio.post('/publicaciones/$id/favorito');
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

  Future<List<String>> getTiposTransaccion() async {
    final response = await _dio.get('/publicaciones/tipos-transaccion');
    return List<String>.from(response.data);
  }

  Future<List<String>> getTiposInmueble() async {
    final response = await _dio.get('/inmuebles/tipos');
    return List<String>.from(response.data);
  }

  Future<List<String>> getUbicaciones() async {
    final response = await _dio.get('/inmuebles/ubicaciones');
    return List<String>.from(response.data);
  }
}

@riverpod
PublicacionRepository publicacionRepository(Ref ref) {
  return PublicacionRepository(ref.watch(dioProvider));
}
