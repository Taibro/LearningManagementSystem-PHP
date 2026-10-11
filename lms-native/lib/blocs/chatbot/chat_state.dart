import '../../models/chatbot/chat_message.dart';

abstract class ChatState {
  final List<ChatMessage> messages;
  ChatState(this.messages);
}

class ChatInitial extends ChatState {
  ChatInitial(List<ChatMessage> messages) : super(messages);
}

class ChatLoading extends ChatState {
  ChatLoading(List<ChatMessage> messages) : super(messages);
}

class ChatSuccess extends ChatState {
  ChatSuccess(List<ChatMessage> messages) : super(messages);
}

class ChatError extends ChatState {
  final String error;
  ChatError(List<ChatMessage> messages, this.error) : super(messages);
}
