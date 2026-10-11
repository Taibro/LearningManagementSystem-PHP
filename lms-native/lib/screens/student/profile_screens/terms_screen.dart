import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../widgets/shared/custom_app_bar.dart';
import '../widgets/shared/mesh_background.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Điều khoản và Chính sách', isGradient: true),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            title: '1. Quy định chung',
                            content: 'Chào mừng bạn đến với Cổng thông tin Sinh viên HUIT. Bằng việc sử dụng ứng dụng này, bạn đồng ý tuân thủ các quy định và chính sách của Nhà trường. Tài khoản được cấp riêng cho từng cá nhân, không được chia sẻ cho người khác.',
                          ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 24),
                          
                          _buildSection(
                            title: '2. Bảo mật thông tin',
                            content: 'Chúng tôi cam kết bảo mật tuyệt đối thông tin cá nhân, điểm số và lịch sử đóng học phí của sinh viên. Ứng dụng có thể yêu cầu quyền truy cập sinh trắc học để tăng cường lớp bảo mật khi đăng nhập.',
                          ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 24),

                          _buildSection(
                            title: '3. Quyền và nghĩa vụ',
                            content: '- Sinh viên có trách nhiệm bảo mật mật khẩu.\n- Thường xuyên cập nhật thông báo từ Nhà trường qua ứng dụng.\n- Không được có hành vi phá hoại hoặc khai thác lỗi hệ thống.',
                          ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 24),

                          _buildSection(
                            title: '4. Giải quyết khiếu nại',
                            content: 'Mọi thắc mắc liên quan đến điểm số, học phí hoặc lỗi hệ thống, sinh viên vui lòng sử dụng tính năng "Trợ giúp & Góp ý" hoặc liên hệ trực tiếp phòng Đào tạo để được hỗ trợ giải quyết trong vòng 48h làm việc.',
                          ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 32),

                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                              label: Text('Tôi đã hiểu', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            ),
                          ).animate().fade(delay: 400.ms).scale(curve: Curves.easeOutBack),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.6,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
