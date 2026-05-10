import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/notification_api.dart';
import '../routing/app_router.dart';

part 'notification_service.g.dart';

const _channelId = 'spaceshift_high';
const _channelName = 'SpaceShift Notificaciones';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService(ref);
}

class NotificationService {
  final Ref _ref;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._ref);

  Future<void> initialize() async {
    await _requestPermissions();
    await _setupAndroidChannel();
    await _registerToken();
    _listenForeground();
    _listenOpenedApp();
  }

  // Llamar desde MainLayoutScreen.initState() — después de que el router ya apunta a /home
  Future<void> checkInitialMessage() async {
    await _checkInitialMessage();
  }

  Future<void> _requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _setupAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
      enableVibration: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  Future<void> _registerToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _ref.read(notificationApiProvider).registerToken(token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _ref.read(notificationApiProvider).registerToken(newToken);
    });
  }

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  void _listenOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_navigate);
  }

  Future<void> _checkInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) _navigate(message);
  }

  void _navigate(RemoteMessage message) {
    final type = message.data['type'];
    if (type == 'NEW_MESSAGE') {
      final conversacionId = message.data['conversacionId'];
      if (conversacionId != null) {
        _ref.read(appRouterProvider).push('/chat_detail/$conversacionId');
      }
    }
  }
}
