import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../widgets/shared/custom_app_bar.dart';
import '../widgets/shared/mesh_background.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    // TODO: Implement actual password change logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đổi mật khẩu thành công!'),
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
            const CustomAppBar(title: 'Đổi mật khẩu', isGradient: true),
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
                                color: const Color(0xFF4F46E5).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.lock_reset_rounded, size: 40, color: Color(0xFF4F46E5)),
                            ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
                             .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms),
                          ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 32),

                          _buildPasswordField(
                            label: 'Mật khẩu hiện tại',
                            controller: _oldPassCtrl,
                            obscureText: _obscureOld,
                            onToggleVisibility: () => setState(() => _obscureOld = !_obscureOld),
                          ).animate().fade(delay: 100.ms).slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 20),

                          _buildPasswordField(
                            label: 'Mật khẩu mới',
                            controller: _newPassCtrl,
                            obscureText: _obscureNew,
                            onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                          ).animate().fade(delay: 200.ms).slideX(begin: 0.1, end: 0),
                          const SizedBox(height: 20),

                          _buildPasswordField(
                            label: 'Nhập lại mật khẩu mới',
                            controller: _confirmPassCtrl,
                            obscureText: _obscureConfirm,
                            onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ).animate().fade(delay: 300.ms).slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 40),

                          ElevatedButton(
                            onPressed: _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Cập nhật mật khẩu',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
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
            obscureText: obscureText,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Nhập $label'.toLowerCase(),
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 22,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
