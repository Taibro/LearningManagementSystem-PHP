import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'login_screen.dart';

/// Screen 3: Chọn vai trò
class RoleSelectionScreen extends StatefulWidget {
  final String schoolName;
  const RoleSelectionScreen({super.key, required this.schoolName});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final _roles = [
    _RoleData(
      title: 'Sinh viên',
      icon: Icons.school_rounded,
      gradient: [const Color(0xFF38BDF8), const Color(0xFF2563EB)],
      description: 'Dành cho sinh viên đang theo học',
    ),
    _RoleData(
      title: 'Cán bộ CNV',
      icon: Icons.public_rounded,
      gradient: [const Color(0xFF34D399), const Color(0xFF059669)],
      description: 'Dành cho giảng viên, cán bộ',
    ),
    _RoleData(
      title: 'Admin trường',
      icon: Icons.admin_panel_settings_rounded,
      gradient: [const Color(0xFFF87171), const Color(0xFFDC2626)],
      description: 'Quản trị viên hệ thống trường',
    ),
  ];

  void _onSelectRole(String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          schoolName: widget.schoolName,
          role: role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Deep modern gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF3730A3)],
                ),
              ),
            ),
          ),
          
          // Abstract floating shapes
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF818CF8).withOpacity(0.4),
                    const Color(0xFF818CF8).withOpacity(0.0),
                  ],
                ),
              ),
            ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4000.ms, curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: -50,
            left: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.3),
                    const Color(0xFF6366F1).withOpacity(0.0),
                  ],
                ),
              ),
            ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true)).slide(begin: const Offset(0, 0), end: const Offset(0.2, -0.2), duration: 5000.ms, curve: Curves.easeInOut),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      // Logout icon
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Greeting
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào,',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        widget.schoolName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        'Vui lòng chọn tuỳ chọn để tiếp tục',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Role cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _roles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        return _RoleCard(
                          role: _roles[i],
                          onTap: () => _onSelectRole(_roles[i].title),
                        ).animate().fade(duration: 500.ms, delay: (200 + i * 100).ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
                      },
                    ),
                  ),
                ),

                // Bottom decorative elements
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories_rounded,
                            color: Colors.white.withOpacity(0.2), size: 28),
                        const SizedBox(width: 24),
                        Icon(Icons.school_rounded,
                            color: Colors.white.withOpacity(0.15), size: 36)
                            .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
                            .slideY(begin: -0.1, end: 0.1, duration: 2000.ms),
                        const SizedBox(width: 24),
                        Icon(Icons.psychology_rounded,
                            color: Colors.white.withOpacity(0.2), size: 28),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role data ──
class _RoleData {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final String description;

  const _RoleData({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.description,
  });
}

// ── Role card ──
class _RoleCard extends StatelessWidget {
  final _RoleData role;
  final VoidCallback onTap;

  const _RoleCard({required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  children: [
                    // Icon with vibrant gradient background
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: role.gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: role.gradient[0].withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(role.icon, color: Colors.white, size: 36),
                    ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms, curve: Curves.easeInOut),
                    const SizedBox(width: 20),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            role.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
