import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chatbot/chat_message.dart';

abstract class CoreChatbotRepository {
  // Load API Key from .env
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Dùng map để tách biệt lịch sử giữa Sinh viên và Giảng viên
  static final Map<String, ChatSession> _globalChatSessions = {};
  static final Map<String, List<ChatMessage>> _globalUiMessages = {};

  final String roleKey;

  CoreChatbotRepository({required this.roleKey});

  void initChatbot(String systemInstruction) {
    if (_apiKey.isNotEmpty) {
      final model = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(systemInstruction),
      );
      
      var history = _globalChatSessions[roleKey]?.history.toList();
      _globalChatSessions[roleKey] = model.startChat(history: history);
      
      if (_globalUiMessages[roleKey] == null) {
        _globalUiMessages[roleKey] = [
          ChatMessage.ai('Xin chào! Mình là Trợ lý ảo của Hệ thống Quản lý Đào tạo. Mình có thể giúp gì cho bạn hôm nay?')
        ];
      }
    }
  }

  List<ChatMessage> get uiMessages => _globalUiMessages[roleKey] ?? [];
  set uiMessages(List<ChatMessage> messages) {
    _globalUiMessages[roleKey] = messages;
  }

  Future<String> sendMessage(String message) async {
    if (_apiKey.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      return 'Lỗi: Chưa cấu hình Gemini API Key. Vui lòng thêm API Key của bạn vào.';
    }

    try {
      final session = _globalChatSessions[roleKey];
      if (session == null) return 'Lỗi: Chưa khởi tạo phiên trò chuyện.';
      
      final response = await session.sendMessage(Content.text(message));
      return response.text ?? 'Xin lỗi, tôi không thể trả lời lúc này.';
    } catch (e) {
      return 'Có lỗi xảy ra: $e';
    }
  }
}
