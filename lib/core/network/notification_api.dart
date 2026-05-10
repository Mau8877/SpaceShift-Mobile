import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dio_provider.dart';

part 'notification_api.g.dart';

@riverpod
NotificationApi notificationApi(Ref ref) {
  return NotificationApi(ref.read(dioProvider));
}

class NotificationApi {
  final Dio _dio;

  NotificationApi(this._dio);

  Future<void> registerToken(String token) async {
    await _dio.post('/notificaciones/token', data: {
      'tokenFcm': token,
      'plataforma': Platform.isAndroid ? 'ANDROID' : 'IOS',
    });
  }

  Future<void> revokeToken(String token) async {
    await _dio.delete('/notificaciones/token', data: {
      'tokenFcm': token,
      'plataforma': Platform.isAndroid ? 'ANDROID' : 'IOS',
    });
  }
}
