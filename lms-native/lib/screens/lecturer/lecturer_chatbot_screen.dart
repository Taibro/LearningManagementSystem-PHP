import 'package:flutter/material.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../blocs/chatbot/chatbot_bloc.dart';
import '../../blocs/chatbot/chat_event.dart';
import '../../blocs/chatbot/chat_state.dart';
import '../../models/chatbot/chat_message.dart';
import '../../repositories/lecturer_chatbot_repository.dart';

import '../../core/network/dio_client.dart';
import '../../repositories/teacher_repository.dart';
import '../../models/lecturer/teacher_profile.dart';
import '../../models/lecturer/monthly_salary.dart';
import '../../models/lecturer/teaching_statistic.dart';
import '../../models/lecturer/teacher_material.dart';

class LecturerChatbotScreen extends StatelessWidget {
  const LecturerChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TeacherRepository(DioClient().dio);
    
    final DateTime now = DateTime.now();

    return FutureBuilder<List<dynamic>>(
      // Chờ lấy thông tin cá nhân trước để có teacherId
      future: repo.getProfile().then((profile) async {
        final salary = await repo.getMonthlySalary(now.year, now.month);
        final stats = await repo.getDashboardStatistics();
        final materials = profile.teacherId != null 
            ? await repo.getMaterials(profile.teacherId!) 
            : <TeacherMaterial>[];

        return [profile, salary, stats, materials];
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(
              child: CustomLoadingIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
            body: Center(
              child: Text('Không thể tải ngữ cảnh: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            ),
          );
        }

        final data = snapshot.data!;
        final profile = data[0] as TeacherProfile;
        final salary = data[1] as MonthlySalary;
        final stats = data[2] as TeachingStatistic;
        final materials = data[3] as List<TeacherMaterial>;

        return BlocProvider(
          create: (context) => ChatbotBloc(LecturerChatbotRepository(
              profile, salary, stats, materials)),
          child: const _LecturerChatbotView(),
        );
      },
    );
  }
}

class _LecturerChatbotView extends StatefulWidget {
  const _LecturerChatbotView();

  @override
  State<_LecturerChatbotView> createState() => _LecturerChatbotViewState();
}

class _LecturerChatbotViewState extends State<_LecturerChatbotView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatbotBloc>().add(SendMessageEvent(text));
      _textController.clear();
      _scrollToBottom();
    }
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
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF4EBFF), // Soft premium purple
            Color(0xFFE0E7FF), // Soft premium blue
            Color(0xFFF0FBFF), // Soft cyan
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.7),
          elevation: 0,
          flexibleSpace: ClipRect(),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF212121), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF8B5CF6), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Trợ lý ảo AI (Giảng viên)',
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatbotBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatSuccess || state is ChatError) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                final messages = state.messages;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: messages.length + (state is ChatLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return _buildLoadingBubble();
                    }
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            if (!message.isUser)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: message.isUser
            ? Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Color(0xFF212121), fontSize: 15),
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CustomLoadingIndicator(),
            ),
            SizedBox(width: 8),
            Text('Đang suy nghĩ...', style: TextStyle(color: Color(0xFF616161), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi...',
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(context),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(context),
            ),
          ),
        ],
      ),
    );
  }
}
