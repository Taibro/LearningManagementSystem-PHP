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
import '../../repositories/student_chatbot_repository.dart';

import '../../core/network/dio_client.dart';
import '../../repositories/student_repository.dart';
import '../../models/student/student_profile.dart';
import '../../models/student/student_schedule.dart';
import '../../models/student/student_grade.dart';
import '../../models/student/student_attendance.dart';
import '../../models/student/student_debt.dart';
import '../../models/student/student_conduct.dart';
import '../../models/student/student_notification.dart';
import '../../models/student/student_survey.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = StudentRepository(DioClient());

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        repo.getProfile(),
        repo.getWeeklySchedule(),
        repo.getGrades(),
        repo.getAttendance(),
        repo.getDebtDetail(),
        repo.getConduct(),
        repo.getNotifications(),
        repo.getSurveys(),
      ]),
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
        final profile = data[0] as StudentProfile;
        final schedules = data[1] as List<StudentSchedule>;
        final grades = data[2] as List<StudentGrade>;
        final attendances = data[3] as List<StudentAttendance>;
        final debts = data[4] as List<StudentDebt>;
        final conducts = data[5] as List<StudentConduct>;
        final notifications = data[6] as List<StudentNotification>;
        final surveys = data[7] as List<StudentSurvey>;

        return BlocProvider(
          create: (context) => ChatbotBloc(StudentChatbotRepository(
              profile, schedules, grades, attendances, debts, conducts, notifications, surveys)),
          child: const _ChatbotView(),
        );
      },
    );
  }
}

class _ChatbotView extends StatefulWidget {
  const _ChatbotView();

  @override
  State<_ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<_ChatbotView> {
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
          flexibleSpace: ClipRect(
            // Cần BackdropFilter nếu muốn làm mờ thật sự nhưng để đơn giản ta dùng opacity
          ),
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
                'Trợ lý ảo AI',
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
          color: message.isUser ? const Color(0xFF1565C0) : Colors.white,
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
              color: Color(0xFF1565C0),
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
