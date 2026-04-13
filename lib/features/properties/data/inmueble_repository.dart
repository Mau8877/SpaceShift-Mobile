import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../domain/inmueble.dart';

part 'inmueble_repository.g.dart';

class InmuebleRepository {
  final Dio _dio;

  InmuebleRepository(this._dio);

  Future<Inmueble> createInmueble(Inmueble inmueble) async {
    final response = await _dio.post(
      '/inmuebles',
      data: inmueble.toJson(),
    );
    return Inmueble.fromJson(response.data);
  }

  Future<List<Inmueble>> getInmuebles() async {
    final response = await _dio.get('/inmuebles');
    return (response.data as List).map((i) => Inmueble.fromJson(i)).toList();
  }

  Future<Inmueble> getInmuebleById(String id) async {
    final response = await _dio.get('/inmuebles/$id');
    return Inmueble.fromJson(response.data);
  }

  Future<Inmueble> updateInmueble(String id, Inmueble inmueble) async {
    final response = await _dio.put(
      '/inmuebles/$id',
      data: inmueble.toJson(),
    );
    return Inmueble.fromJson(response.data);
  }

  Future<void> deleteInmueble(String id) async {
    await _dio.delete('/inmuebles/$id');
  }
}

@riverpod
InmuebleRepository inmuebleRepository(Ref ref) {
  return InmuebleRepository(ref.watch(dioProvider));
}
