import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/shared/lecturer_custom_app_bar.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Góp ý ứng dụng', icon: Icons.chat_bubble_rounded),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFFF59E0B), size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Gửi phản hồi của bạn',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chúng tôi luôn trân trọng những góp ý từ Giảng viên để cải thiện hệ thống.',
                      style: TextStyle(color: Color(0xFF64748B), height: 1.5, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Nhập nội dung góp ý...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Cảm ơn bạn đã góp ý!'),
                              backgroundColor: const Color(0xFFF59E0B),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('GỬI GÓP Ý', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            ),
          ),
        ],
      ),
    );
  }
}
