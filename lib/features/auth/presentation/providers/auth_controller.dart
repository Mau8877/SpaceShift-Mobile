import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/notification_api.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/auth_repository.dart';

part 'auth_controller.g.dart';

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

  Future<void> logout() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await ref.read(notificationApiProvider).revokeToken(fcmToken);
    }
    await ref.read(authRepositoryProvider).logout();
  }
}
