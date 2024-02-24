import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_notify_app/main.dart';
import 'package:my_notify_app/page/notification_screen.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
}

class FireBaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _andriondChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.defaultImportance,
  );
  final _localNotificationManager = FlutterLocalNotificationsPlugin();
  void handleMessage(RemoteMessage? message) {
    log('handleMessage: $message');
    if (message == null) return;
    navigetorKey.currentState
        ?.pushNamed(NotificationScreen.routeName, arguments: message);
  }

  Future initLocalNotification() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotificationManager.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        log('onDidReceiveNotificationResponse: $response');
        final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
        handleMessage(message);
      },
    );
    final platform =
        _localNotificationManager.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_andriondChannel);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    log('token: $token');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    initPushNotification();
    initLocalNotification();
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) {
        final notification = message.notification;
        if (notification != null) {
          log('notification title: ${notification.title}');
          log('notification body: ${notification.body}');

          _localNotificationManager.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _andriondChannel.id,
                _andriondChannel.name,
                channelDescription: _andriondChannel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.high,
              ),
            ),
            payload: jsonEncode(message.toMap()),
          );
        }
      },
    );
  }
}
