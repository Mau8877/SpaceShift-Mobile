import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/notification_api.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/auth_repository.dart';
import '../../domain/register_request.dart';

part 'auth_controller.g.dart';

enum RecoveryStep { correo, codigo, nuevaPassword }

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
    if (!state.hasError) {
      await ref.read(notificationServiceProvider).initialize();
    }
    return !state.hasError;
  }

  Future<bool> register(RegisterRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(request),
    );
    return !state.hasError;
  }

  Future<bool> solicitarRecuperacion(String correo) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).solicitarRecuperacion(correo),
    );
    return !state.hasError;
  }

  Future<bool> validarCodigo(String correo, String codigo) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).validarCodigo(correo, codigo),
    );
    return !state.hasError;
  }

  Future<bool> cambiarPassword(String correo, String codigo, String nuevaPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).cambiarPassword(correo, codigo, nuevaPassword),
    );
    return !state.hasError;
  }

  Future<void> logout() async {
    // Capturamos las referencias ANTES de los awaits para evitar el error de "disposed ref"
    final notificationApi = ref.read(notificationApiProvider);
    final authRepository = ref.read(authRepositoryProvider);

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await notificationApi.revokeToken(fcmToken);
      }
    } catch (e) {
      // Si falla lo de Firebase/Notificaciones, igual queremos que cierre sesión
      debugPrint('Error revocando token FCM: $e');
    }
    
    await authRepository.logout();
  }
}
