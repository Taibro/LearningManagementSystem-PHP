import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/shared/lecturer_custom_app_bar.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Điều khoản chính sách', icon: Icons.description_rounded),
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
                    BoxShadow(color: const Color(0xFF6B4FA0).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
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
                            color: const Color(0xFF6B4FA0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.gavel_rounded, color: Color(0xFF6B4FA0), size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'ĐIỀU KHOẢN SỬ DỤNG HỆ THỐNG',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 24),
                    _buildTermSection('1. Bảo mật thông tin', 'Giảng viên có trách nhiệm bảo mật tài khoản cá nhân, không chia sẻ mật khẩu cho người khác.'),
                    const SizedBox(height: 20),
                    _buildTermSection('2. Trách nhiệm cập nhật dữ liệu', 'Kết quả điểm danh, điểm số phải được cập nhật đúng hạn theo quy định của nhà trường.'),
                    const SizedBox(height: 20),
                    _buildTermSection('3. Xử lý vi phạm', 'Mọi hành vi can thiệp trái phép vào hệ thống sẽ bị xử lý theo quy chế của nhà trường và pháp luật.'),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
