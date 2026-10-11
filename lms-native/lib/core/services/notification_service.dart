import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../globals.dart';
import '../storage/secure_storage.dart';
import '../../models/student/teacher_chat_response.dart';
import '../../screens/student/features_screens/student_realtime_chat_screen.dart';
import '../../screens/lecturer/features_screens/lecturer_realtime_chat_screen.dart';

class NotificationService {
  static OverlayEntry? _overlayEntry;

  static void showChatNotification({
    required String senderName,
    required String senderEmail,
    required String content,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Remove previous notification if it exists
    _overlayEntry?.remove();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildNotification(
        context,
        senderName: senderName,
        senderEmail: senderEmail,
        content: content,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    });
  }

  static Widget _buildNotification(
    BuildContext context, {
    required String senderName,
    required String senderEmail,
    required String content,
  }) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () async {
            // Dismiss banner
            _overlayEntry?.remove();
            _overlayEntry = null;

            // Navigate to chat screen
            final role = await SecureStorage.getRole();
            if (role == 'STUDENT') {
              final teacher = TeacherChatResponse(
                email: senderEmail, 
                teacherName: senderName,
                teacherId: 0,
                departmentName: '',
              );
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => StudentRealtimeChatScreen(teacher: teacher),
                ),
              );
            } else if (role == 'LECTURER' || role == 'TEACHER') {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => LecturerRealtimeChatScreen(
                    studentEmail: senderEmail,
                    studentName: senderName,
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                  radius: 20,
                  child: Text(
                    senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF4F46E5),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: -1.0, end: 0.0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
      ),
    );
  }
}
