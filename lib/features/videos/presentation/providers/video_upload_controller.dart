import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/video_repository.dart';

part 'video_upload_controller.g.dart';

class VideoUploadState {
  final bool isUploading;
  final double progress;
  final String? idPublicacion;
  final String? error;
  final bool completed;

  VideoUploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.idPublicacion,
    this.error,
    this.completed = false,
  });

  VideoUploadState copyWith({
    bool? isUploading,
    double? progress,
    String? idPublicacion,
    String? error,
    bool? completed,
  }) {
    return VideoUploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      idPublicacion: idPublicacion ?? this.idPublicacion,
      error: error,
      completed: completed ?? this.completed,
    );
  }
}

@riverpod
class VideoUploadController extends _$VideoUploadController {
  @override
  VideoUploadState build() {
    return VideoUploadState();
  }

  void reset() {
    state = VideoUploadState();
  }

  Future<void> iniciarSubida({
    required String idPublicacion,
    required File file,
    required int duracionSegundos,
    required String formato,
  }) async {
    state = state.copyWith(
      isUploading: true, 
      progress: 0.0, 
      idPublicacion: idPublicacion, 
      error: null, 
      completed: false
    );
    
    try {
      final repository = ref.read(videoRepositoryProvider);
      
      // 1. Obtener S3 Upload URL
      final extension = '.${file.path.split('.').last}';
      final uploadData = await repository.getUploadUrl(extension);
      final uploadUrl = uploadData['uploadUrl'];
      final keyS3 = uploadData['key'];
      
      // 2. Subir a S3 con progreso
      await repository.uploadFileToS3(uploadUrl, file, (int sent, int total) {
        if (total > 0) {
           state = state.copyWith(progress: sent / total);
        }
      });
      
      // 3. Registrar video en backend
      final fileName = file.path.split(Platform.pathSeparator).last;
      final size = await file.length();
      
      await repository.registrarVideo(
        idPublicacion: idPublicacion,
        keyS3: keyS3,
        nombreArchivo: fileName,
        tamanoBytes: size,
        duracionSegundos: duracionSegundos,
        formato: formato,
      );
      
      state = state.copyWith(isUploading: false, progress: 1.0, completed: true);
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
    }
  }
}
