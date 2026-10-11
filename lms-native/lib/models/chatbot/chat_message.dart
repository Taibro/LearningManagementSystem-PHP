class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.ai(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      createdAt: DateTime.now(),
    );
  }
}
