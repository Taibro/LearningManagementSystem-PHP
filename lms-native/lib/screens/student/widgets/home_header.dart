import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/shared_notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Glassmorphism Header
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // --- Animated Avatar ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ).animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
                   .scaleXY(begin: 1.0, end: 1.05, duration: 2.seconds),
                  
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: const Color(0xFFE0E7FF),
                    ),
                    child: const Icon(Icons.person_rounded, size: 30, color: Color(0xFF4F46E5)),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // --- Greeting Text ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xin chào,',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nguyễn Thanh Tài',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fade(duration: 600.ms, delay: 200.ms).slideX(begin: 0.1, end: 0),
              
              // --- Notification Bell ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SharedNotificationsScreen()),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF334155),
                        size: 24,
                      ),
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444), // Red dot
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (AnimationController controller) => controller.repeat())
                         .scaleXY(begin: 0.8, end: 1.2, duration: 1.seconds, curve: Curves.easeInOut)
                         .then().scaleXY(begin: 1.2, end: 0.8, duration: 1.seconds, curve: Curves.easeInOut),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 400.ms, delay: 400.ms, curve: Curves.easeOutBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
