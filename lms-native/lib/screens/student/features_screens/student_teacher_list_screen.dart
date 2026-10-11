import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/student/teacher_chat_response.dart';
import '../../../repositories/student_repository.dart';
import '../widgets/shared/custom_app_bar.dart';
import 'student_realtime_chat_screen.dart';

class StudentTeacherListScreen extends StatefulWidget {
  const StudentTeacherListScreen({super.key});

  @override
  State<StudentTeacherListScreen> createState() => _StudentTeacherListScreenState();
}

class _StudentTeacherListScreenState extends State<StudentTeacherListScreen> {
  late StudentRepository _repository;
  bool _isLoading = true;
  List<TeacherChatResponse> _teachers = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _repository = context.read<StudentRepository>();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      // Fetching teachers for the current semester (or 0 for all time enrolled)
      // Here we assume 0 fetches enrolled/pending for this semester based on API design
      final teachers = await _repository.getTeachersForChat(semesterId: 0);
      setState(() {
        _teachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const CustomAppBar(
            title: 'Trò chuyện cùng Giảng viên',
            isGradient: true,
            paddingBottom: 24,
            fontSize: 20,
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTeachers,
              child: const Text('Thử lại'),
            )
          ],
        ),
      );
    }

    if (_teachers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_off_rounded, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            Text(
              'Bạn chưa có môn học nào trong học kỳ này.',
              style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _teachers.length,
      itemBuilder: (context, index) {
        final teacher = _teachers[index];
        return _buildTeacherCard(teacher, index);
      },
    );
  }

  Widget _buildTeacherCard(TeacherChatResponse teacher, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentRealtimeChatScreen(teacher: teacher),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                  child: Text(
                    teacher.teacherName.isNotEmpty ? teacher.teacherName[0].toUpperCase() : 'GV',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.teacherName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        teacher.departmentName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      if (teacher.email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(
                              teacher.email,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF4F46E5), size: 20),
                )
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
  }
}
