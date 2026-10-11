import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/chatbot/chat_message.dart';
import '../../repositories/core_chatbot_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatbotBloc extends Bloc<ChatEvent, ChatState> {
  final CoreChatbotRepository _repository;

  ChatbotBloc(this._repository) : super(ChatInitial(_repository.uiMessages)) {
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    final userMessage = ChatMessage.user(event.message);
    
    // Tạo danh sách tin nhắn mới bao gồm tin nhắn của user
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);
    
    // Lưu tạm vào repository để nếu thoát màn hình vẫn còn giữ
    _repository.uiMessages = updatedMessages;
    
    // Phát ra trạng thái Loading
    emit(ChatLoading(updatedMessages));

    try {
      // Gọi API AI
      final aiResponseText = await _repository.sendMessage(event.message);
      
      // Thêm phản hồi của AI vào danh sách
      final aiMessage = ChatMessage.ai(aiResponseText);
      final finalMessages = List<ChatMessage>.from(updatedMessages)..add(aiMessage);
      
      // Lưu chính thức vào repository
      _repository.uiMessages = finalMessages;
      
      emit(ChatSuccess(finalMessages));
    } catch (e) {
      // Trong trường hợp lỗi, vẫn giữ lại các tin nhắn cũ và báo lỗi
      emit(ChatError(updatedMessages, e.toString()));
    }
  }
}
