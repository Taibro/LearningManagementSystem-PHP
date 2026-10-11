import 'package:flutter/material.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:learning_management_app/screens/student/home_screen.dart';
import 'package:learning_management_app/screens/lecturer/lecturer_main_layout.dart';
import 'package:learning_management_app/screens/admin/admin_main_layout.dart';
import 'package:learning_management_app/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_app/blocs/auth/auth_bloc.dart';
import 'package:learning_management_app/blocs/auth/auth_event.dart';
import 'package:learning_management_app/blocs/auth/auth_state.dart';

/// Screen 4: Đăng nhập
/// Premium Login form with biometric auth, glassmorphism, and mesh gradients.
class LoginScreen extends StatefulWidget {
  final String schoolName;
  final String role;

  const LoginScreen({
    super.key,
    required this.schoolName,
    required this.role,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String get _roleLabel {
    switch (widget.role) {
      case 'Sinh viên': return 'Sinh viên';
      case 'Cán bộ CNV': return 'Cán bộ CNV';
      case 'Admin trường': return 'Admin trường';
      default: return widget.role;
    }
  }

  Color get _accentColor {
    switch (widget.role) {
      case 'Sinh viên': return const Color(0xFF2563EB); // Blue
      case 'Cán bộ CNV': return const Color(0xFF059669); // Emerald
      case 'Admin trường': return const Color(0xFFDC2626); // Red
      default: return const Color(0xFF2563EB);
    }
  }

  List<Color> get _headerGradient {
    switch (widget.role) {
      case 'Sinh viên': return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
      case 'Cán bộ CNV': return [const Color(0xFF10B981), const Color(0xFF047857)];
      case 'Admin trường': return [const Color(0xFFEF4444), const Color(0xFFB91C1C)];
      default: return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
    }
  }

  void _onLogin() {
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    String userType = 'STUDENT';
    if (widget.role == 'Cán bộ CNV') userType = 'LECTURER';
    if (widget.role == 'Admin trường') userType = 'SCHOOL_ADMIN';

    context.read<AuthBloc>().add(AuthLoginRequested(
      loginCode: _userCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      userType: userType,
      schoolCode: 'HUIT', // TODO: Lấy mã trường thực tế
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Widget destination;
          switch (widget.role) {
            case 'Sinh viên': destination = const MainLayout(); break;
            case 'Cán bộ CNV': destination = const LecturerMainLayout(); break;
            case 'Admin trường': destination = const AdminMainLayout(); break;
            default: destination = const MainLayout();
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => destination),
            (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Transform.translate(
                offset: const Offset(0, -32),
                child: _buildLoginForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 56),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _headerGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: _headerGradient[1].withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () => Navigator.pop(context),
              ).animate().fade(duration: 400.ms),
            ),
            const SizedBox(height: 20),
            // Title & role & lock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đăng nhập',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ).animate().fade().slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                          ),
                          child: Text(
                            _roleLabel,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fade(delay: 100.ms).slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                      ],
                    ),
                  ),
                  _buildLockDecoration().animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockDecoration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring (rotated)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
        ).animate(onPlay: (AnimationController controller) => controller.repeat())
         .rotate(duration: 8000.ms, curve: Curves.linear),
        // Inner circle (pulsing)
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_rounded,
            color: Colors.white.withOpacity(0.9),
            size: 26,
          ),
        ).animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
         .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1500.ms, curve: Curves.easeInOut),
        // Small dots
        ...List.generate(4, (i) {
          final angle = (i * math.pi / 2) + math.pi / 4;
          return Positioned(
            left: 40 + 35 * math.cos(angle) - 3,
            top: 40 + 35 * math.sin(angle) - 3,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // School info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accentColor.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_rounded, color: _accentColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.schoolName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 28),

          // Username
          _buildLabel('Tên đăng nhập'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _userCtrl,
            hint: 'Nhập mã sinh viên / mã nhân viên',
            icon: Icons.person_outline_rounded,
          ).animate().fade(delay: 300.ms).slideX(begin: -0.1, end: 0),

          const SizedBox(height: 20),

          // Password
          _buildLabel('Mật khẩu'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passCtrl,
            hint: 'Nhập mật khẩu',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
          ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Login button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CustomLoadingIndicator(),
                        )
                      : Text(
                          'Đăng nhập',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ).animate().fade(delay: 600.ms).scale(curve: Curves.easeOutBack);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePass : false,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 24),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 24,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
