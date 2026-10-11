import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

class LecturerChangePasswordScreen extends StatefulWidget {
  const LecturerChangePasswordScreen({super.key});

  @override
  State<LecturerChangePasswordScreen> createState() =>
      _LecturerChangePasswordScreenState();
}

class _LecturerChangePasswordScreenState
    extends State<LecturerChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đổi mật khẩu thành công'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            hintText: 'Nhập $label',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, color: const Color(0xFF6B4FA0), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6B4FA0), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Đổi mật khẩu', icon: Icons.lock_rounded),
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
                          child: const Icon(Icons.security_rounded, color: Color(0xFF6B4FA0), size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Bảo mật tài khoản',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Mật khẩu hiện tại',
                      icon: Icons.lock_outline_rounded,
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrent,
                      onToggleVisibility: () {
                        setState(() => _obscureCurrent = !_obscureCurrent);
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Mật khẩu mới',
                      icon: Icons.key_rounded,
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      onToggleVisibility: () {
                        setState(() => _obscureNew = !_obscureNew);
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Xác nhận mật khẩu mới',
                      icon: Icons.check_circle_outline_rounded,
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      onToggleVisibility: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4FA0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'CẬP NHẬT MẬT KHẨU',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
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
