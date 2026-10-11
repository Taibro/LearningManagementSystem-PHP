import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/stomp_chat_service.dart';
import '../../../core/storage/secure_storage.dart';

class ChatMessage {
  final String senderEmail;
  final String content;
  final String timestamp;
  final bool isMine;

  ChatMessage({
    required this.senderEmail,
    required this.content,
    required this.timestamp,
    required this.isMine,
  });
}

class LecturerRealtimeChatScreen extends StatefulWidget {
  final String studentEmail;
  final String studentName;

  const LecturerRealtimeChatScreen({
    super.key,
    required this.studentEmail,
    required this.studentName,
  });

  @override
  State<LecturerRealtimeChatScreen> createState() => _LecturerRealtimeChatScreenState();
}

class _LecturerRealtimeChatScreenState extends State<LecturerRealtimeChatScreen> {
  final StompChatService _chatService = StompChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isConnected = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryAndConnect();
  }

  Future<void> _loadHistoryAndConnect() async {
    // 1. Fetch History
    try {
      final token = await SecureStorage.getToken();
      final url = Uri.parse('http://localhost:8080/api/chat/history?userEmail=${widget.studentEmail}');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _messages.addAll(data.map((msg) {
            return ChatMessage(
              senderEmail: msg['senderEmail'] ?? '',
              content: msg['content'] ?? '',
              timestamp: msg['timestamp'] ?? '',
              isMine: msg['senderEmail'] != widget.studentEmail,
            );
          }));
          _isLoadingHistory = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      setState(() => _isLoadingHistory = false);
    }

    // 2. Setup Global STOMP Listeners
    _chatService.currentChatEmail = widget.studentEmail;
    _chatService.onMessageReceived = (message) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            senderEmail: message['senderEmail'] ?? '',
            content: message['content'] ?? '',
            timestamp: message['timestamp'] ?? '',
            isMine: message['senderEmail'] != widget.studentEmail,
          ));
        });
        _scrollToBottom();
      }
    };
    
    await _chatService.initGlobalConnection();
    
    setState(() {
      _isConnected = true; // Assuming global connection is either already active or connects quickly
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _chatService.sendMessage(widget.studentEmail, text);
    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    if (_chatService.currentChatEmail == widget.studentEmail) {
      _chatService.currentChatEmail = null;
      _chatService.onMessageReceived = null;
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F4FF), // Soft premium blue
            Color(0xFFFAFAFA), // White-ish
            Color(0xFFF5E6FF), // Soft premium purple
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white.withOpacity(0.8),
          flexibleSpace: ClipRect(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                    child: Text(
                      widget.studentName.isNotEmpty ? widget.studentName[0].toUpperCase() : 'SV',
                      style: GoogleFonts.inter(color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.studentName,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _isConnected ? 'Đang hoạt động' : 'Đang kết nối...',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: _isLoadingHistory
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Text(
                              'Hãy là người bắt đầu cuộc trò chuyện',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              return _buildMessageBubble(msg);
                            },
                          ),
                  ),
                  _buildInputArea(),
                ],
              ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: msg.isMine 
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)], // Indigo gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: msg.isMine ? null : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: msg.isMine ? const Radius.circular(4) : const Radius.circular(20),
            bottomLeft: !msg.isMine ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: msg.isMine ? const Color(0xFF4F46E5).withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          msg.content,
          style: GoogleFonts.inter(
            color: msg.isMine ? Colors.white : const Color(0xFF1E293B),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ).animate().fade(duration: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Soạn tin nhắn...',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ).animate().scale(delay: 200.ms),
            ),
          ],
        ),
      ),
    );
  }
}
