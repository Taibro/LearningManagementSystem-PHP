import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../storage/secure_storage.dart';
import '../services/notification_service.dart';

class StompChatService {
  static final StompChatService _instance = StompChatService._internal();

  factory StompChatService() {
    return _instance;
  }

  StompChatService._internal();

  StompClient? _stompClient;
  
  // Callback when a message is received specifically for a chat screen
  Function(Map<String, dynamic>)? onMessageReceived;
  Function()? onConnected;
  
  // Track who we are currently chatting with to prevent showing drop-down banner for them
  String? currentChatEmail;

  Future<void> initGlobalConnection() async {
    if (_stompClient != null && _stompClient!.isActive) return;

    final token = await SecureStorage.getToken();
    if (token == null) return;
    
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8080/ws', // For real device with adb reverse or local testing
        onConnect: (StompFrame frame) {
          if (onConnected != null) onConnected!();
          
          // Subscribe to user's private queue
          _stompClient!.subscribe(
            destination: '/user/queue/messages',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final message = json.decode(frame.body!);
                
                // If we are on the chat screen with this sender, pass it to the screen
                if (onMessageReceived != null && currentChatEmail == message['senderEmail']) {
                  onMessageReceived!(message);
                } else {
                  // Otherwise, show global in-app notification banner
                  NotificationService.showChatNotification(
                    senderName: message['senderName'] ?? message['senderEmail'] ?? 'Người dùng',
                    senderEmail: message['senderEmail'] ?? '',
                    content: message['content'] ?? '',
                  );
                }
              }
            },
          );
        },
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        onWebSocketError: (dynamic error) => debugPrint('WebSocket Error: $error'),
        onStompError: (StompFrame frame) => debugPrint('Stomp Error: ${frame.body}'),
        onDisconnect: (StompFrame frame) => debugPrint('Disconnected'),
      ),
    );
    
    _stompClient!.activate();
  }

  void sendMessage(String receiverEmail, String content) {
    if (_stompClient != null && _stompClient!.isActive) {
      _stompClient!.send(
        destination: '/app/chat.send',
        body: json.encode({
          'receiverEmail': receiverEmail,
          'content': content,
        }),
      );
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
