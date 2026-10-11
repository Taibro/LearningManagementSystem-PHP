import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../widgets/shared/custom_app_bar.dart';
import '../widgets/shared/mesh_background.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập đầy đủ thông tin'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // TODO: Send feedback API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gửi góp ý thành công. Cảm ơn bạn!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Trợ giúp & Góp ý', isGradient: true),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.support_agent_rounded, size: 40, color: Color(0xFFF59E0B)),
                            ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
                             .slideY(begin: -0.05, end: 0.05, duration: 2000.ms),
                          ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 16),
                          
                          Text(
                            'Chúng tôi luôn lắng nghe bạn',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ).animate().fade(delay: 100.ms),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy gửi mọi thắc mắc hoặc góp ý để chúng tôi cải thiện dịch vụ.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ).animate().fade(delay: 200.ms),
                          const SizedBox(height: 32),

                          _buildInputField(
                            label: 'Tiêu đề',
                            hint: 'Ví dụ: Lỗi hiển thị điểm số',
                            controller: _titleCtrl,
                            maxLines: 1,
                          ).animate().fade(delay: 300.ms).slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: 'Nội dung góp ý',
                            hint: 'Mô tả chi tiết vấn đề bạn đang gặp phải...',
                            controller: _contentCtrl,
                            maxLines: 5,
                          ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),
                          const SizedBox(height: 40),

                          ElevatedButton.icon(
                            onPressed: _onSubmit,
                            icon: const Icon(Icons.send_rounded, size: 20),
                            label: Text(
                              'Gửi góp ý',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ).animate().fade(delay: 500.ms).scale(curve: Curves.easeOutBack),
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
