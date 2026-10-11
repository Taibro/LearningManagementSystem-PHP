import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning_management_app/models/admin/schedule_exception_response.dart';
import '../../core/widgets/custom_loading_indicator.dart';

import '../../core/network/dio_client.dart';
import '../../blocs/chatbot/chatbot_bloc.dart';
import '../../blocs/chatbot/chat_event.dart';
import '../../blocs/chatbot/chat_state.dart';
import '../../repositories/admin_repository.dart';
import '../../repositories/admin_chatbot_repository.dart';

class AdminChatbotScreen extends StatefulWidget {
  const AdminChatbotScreen({super.key});

  @override
  State<AdminChatbotScreen> createState() => _AdminChatbotScreenState();
}

class _AdminChatbotScreenState extends State<AdminChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AdminRepository _adminRepo;
  AdminChatbotRepository? _chatbotRepo;
  bool _isLoadingContext = true;
  String? _contextError;

  @override
  void initState() {
    super.initState();
    _adminRepo = AdminRepository(DioClient().dio);
    _loadContext();
  }

  Future<void> _loadContext() async {
    try {
      final results = await Future.wait([
        _adminRepo.getDashboardStats(),
        _adminRepo.getUnpaidInvoices(),
        _adminRepo.getAllStudents(),
        _adminRepo.getAllTeachers(),
        _adminRepo.getAllClasses(),
        _adminRepo.getAllCourses(),
      ]);

      setState(() {
        _chatbotRepo = AdminChatbotRepository(
          stats: results[0] as dynamic,
          unpaidInvoices: results[1] as dynamic,
          students: results[2] as dynamic,
          teachers: results[3] as dynamic,
          classes: results[4] as dynamic,
          courses: results[5] as dynamic,
        );
        _isLoadingContext = false;
      });
    } catch (e) {
      setState(() {
        _contextError = e.toString();
        _isLoadingContext = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      appBar: AppBar(
        backgroundColor: const Color(0xFFC62828), // Màu Đỏ đặc trưng của Admin
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trợ lý ảo AI',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Quản trị nhà trường',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _isLoadingContext
          ? Center(child: CustomLoadingIndicator())
          : _contextError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Không thể tải ngữ cảnh: $_contextError',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : BlocProvider(
                  create: (_) => ChatbotBloc(_chatbotRepo!),
                  child: Column(
                    children: [
                      Expanded(
                        child: BlocConsumer<ChatbotBloc, ChatState>(
                          listener: (context, state) {
                            if (state is ChatSuccess || state is ChatError) {
                              Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                            }
                          },
                          builder: (context, state) {
                            if (state is ChatLoading && state.messages.isEmpty) {
                              return Center(child: CustomLoadingIndicator());
                            }

                            final messages = state.messages;
                            if (messages.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC62828).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.support_agent_rounded, size: 64, color: Color(0xFFC62828)),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Chào Thầy/Cô,\nAI có thể giúp gì cho Thầy/Cô hôm nay?',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
                              );
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length + (state is ChatLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == messages.length) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20).copyWith(topLeft: const Radius.circular(4)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
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
                                          Text('AI đang suy nghĩ...', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn();
                                }

                                final msg = messages[index];
                                final isUser = msg.isUser;
                                return Align(
                                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isUser ? const Color(0xFFC62828) : Colors.white,
                                      borderRadius: BorderRadius.circular(20).copyWith(
                                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                                        topLeft: !isUser ? const Radius.circular(4) : const Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        if (!isUser)
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                      ],
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: GoogleFonts.inter(
                                        color: isUser ? Colors.white : const Color(0xFF334155),
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ).animate().slideX(begin: isUser ? 0.2 : -0.2, end: 0, duration: 300.ms).fadeIn(),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: BlocBuilder<ChatbotBloc, ChatState>(
                                    builder: (context, state) {
                                      final isLoading = state is ChatLoading;
                                      return TextField(
                                        controller: _controller,
                                        enabled: !isLoading,
                                        decoration: InputDecoration(
                                          hintText: 'Hỏi AI về quản trị trường học...',
                                          hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                        ),
                                        textInputAction: TextInputAction.send,
                                        onSubmitted: (val) {
                                          if (val.trim().isNotEmpty && !isLoading) {
                                            context.read<ChatbotBloc>().add(SendMessageEvent(val.trim()));
                                            _controller.clear();
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              BlocBuilder<ChatbotBloc, ChatState>(
                                builder: (context, state) {
                                  final isLoading = state is ChatLoading;
                                  return GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            final val = _controller.text.trim();
                                            if (val.isNotEmpty) {
                                              context.read<ChatbotBloc>().add(SendMessageEvent(val));
                                              _controller.clear();
                                            }
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isLoading ? const Color(0xFF94A3B8) : const Color(0xFFC62828),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          if (!isLoading)
                                            BoxShadow(
                                              color: const Color(0xFFC62828).withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                        ],
                                      ),
                                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
