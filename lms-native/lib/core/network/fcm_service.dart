import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_management_app/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class FcmService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // 1. Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // 2. Get FCM Token
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await _sendTokenToServer(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // 3. Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _sendTokenToServer(newToken);
    });

    // 4. Handle messages in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        // TODO: Show local notification or snackbar if needed
      }
    });
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      final dio = DioClient().dio;
      await dio.put('/fcm/token', data: {'token': token});
      debugPrint('Sent FCM Token to Server successfully');
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }
}

// Global background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp()` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}
