import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'choose_school_screen.dart';
import 'role_selection_screen.dart';
import 'data/mock_school_data.dart';
import '../student/widgets/shared/mesh_background.dart'; // Ensure correct path or create a local mesh

/// Screen 1: Nhập mã trường
class SchoolCodeScreen extends StatefulWidget {
  const SchoolCodeScreen({super.key});

  @override
  State<SchoolCodeScreen> createState() => _SchoolCodeScreenState();
}

class _SchoolCodeScreenState extends State<SchoolCodeScreen> {
  final _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onContinue() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã trường'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseSchoolScreen(initialCode: code),
      ),
    );
  }

  void _onSearchSchool() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChooseSchoolScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient instead of full Mesh (for auth flow premium look)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF3B82F6), Color(0xFF0284C7)],
                ),
              ),
            ),
          ),
          
          // Abstract floating shapes
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 3000.ms, curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true)).slide(begin: const Offset(0, 0), end: const Offset(0.1, -0.1), duration: 4000.ms, curve: Curves.easeInOut),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: _buildHeroIcon(),
                        ),
                      ),
                      _buildFormCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: const Icon(Icons.school_rounded, size: 56, color: Colors.white),
              ),
            ),
          ),
        ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true)).slideY(begin: -0.05, end: 0.05, duration: 2000.ms, curve: Curves.easeInOut),
        
        Positioned(
          top: 0,
          right: -10,
          child: const Icon(Icons.star_rounded, color: Colors.yellowAccent, size: 28)
              .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1500.ms),
        ),
        Positioned(
          bottom: 10,
          left: -20,
          child: const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 32)
              .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
              .rotate(begin: -0.1, end: 0.1, duration: 2500.ms),
        ),
      ],
    ).animate().fade(duration: 800.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 48),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Nhập mã trường',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng nhập mã hoặc chọn trường để tiếp tục',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _codeController,
                    focusNode: _focusNode,
                    onChanged: (val) {
                      final q = val.trim().toLowerCase();
                      if (q.isNotEmpty) {
                        try {
                          final match = mockSchools.firstWhere(
                            (s) => s.code.toLowerCase() == q
                          );
                          _focusNode.unfocus();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoleSelectionScreen(schoolName: match.name),
                            ),
                          );
                        } catch (e) {
                          // No exact match yet, do nothing
                        }
                      }
                    },
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Nhập mã trường...',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _onSearchSchool,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF3B82F6), size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _onContinue,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 32),
            ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1000.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOutQuart).fade();
  }
}
