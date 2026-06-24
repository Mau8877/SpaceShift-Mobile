import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';

part 'video_repository.g.dart';

class VideoRepository {
  final Dio _dio;

  VideoRepository(this._dio);

  Future<Map<String, dynamic>> getUploadUrl(String extension) async {
    final response = await _dio.get(
      '/videos/upload-url',
      queryParameters: {'extension': extension},
    );
    return response.data; // { 'uploadUrl': '...', 'key': '...' }
  }

  Future<Map<String, dynamic>> cotizar(int duracionSegundos, String formato) async {
    final response = await _dio.get(
      '/videos/cotizar',
      queryParameters: {
        'duracionSegundos': duracionSegundos,
        'formato': formato,
      },
    );
    return response.data; // { 'costoCreditos': 5, 'saldoSuficiente': true }
  }

  Future<void> uploadFileToS3(String uploadUrl, File file, void Function(int, int) onSendProgress) async {
    // Para S3 directo no usamos la baseUrl configurada ni los interceptores de Auth
    final s3Dio = Dio(); 
    final len = await file.length();
    
    await s3Dio.put(
      uploadUrl,
      data: file.openRead(),
      options: Options(
        headers: {
          Headers.contentLengthHeader: len,
          // S3 puede requerir el Content-Type adecuado, ej. 'video/mp4'
          'Content-Type': 'video/mp4',
        },
      ),
      onSendProgress: onSendProgress,
    );
  }

  Future<Map<String, dynamic>> registrarVideo({
    required String idPublicacion,
    required String keyS3,
    required String nombreArchivo,
    required int tamanoBytes,
    required int duracionSegundos,
    required String formato,
  }) async {
    final response = await _dio.post(
      '/videos/publicaciones/$idPublicacion',
      data: {
        'keyS3': keyS3,
        'nombreArchivo': nombreArchivo,
        'tamanoBytes': tamanoBytes,
        'duracionSegundos': duracionSegundos,
        'formato': formato,
      },
    );
    return response.data;
  }
}

@riverpod
VideoRepository videoRepository(Ref ref) {
  return VideoRepository(ref.watch(dioProvider));
}
