import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class AdminAnimatedBackground extends StatelessWidget {
  const AdminAnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Premium Mesh Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8FAFC), // Slate 50
                Color(0xFFEEF2FF), // Indigo 50
                Color(0xFFF1F5F9), // Slate 100
                Color(0xFFE0E7FF), // Indigo 100
              ],
            ),
          ),
        ),
        
        // Floating Animated Elements
        Positioned(
          top: -50,
          left: -50,
          child: _buildFloatingBlob(
            color: const Color(0xFF3F51B5).withOpacity(0.05),
            size: 300,
            delay: 0,
          ),
        ),
        Positioned(
          top: 200,
          right: -100,
          child: _buildFloatingBlob(
            color: const Color(0xFF818CF8).withOpacity(0.05),
            size: 250,
            delay: 1000,
          ),
        ),
        Positioned(
          bottom: -100,
          left: 100,
          child: _buildFloatingBlob(
            color: const Color(0xFFC7D2FE).withOpacity(0.08),
            size: 350,
            delay: 2000,
          ),
        ),
        
        // Animated Icons (Subtle)
        Positioned(
          top: 150,
          left: 40,
          child: _buildFloatingIcon(Icons.dashboard_customize_rounded, delay: 0),
        ),
        Positioned(
          top: 350,
          right: 40,
          child: _buildFloatingIcon(Icons.auto_graph_rounded, delay: 1500),
        ),
        Positioned(
          bottom: 250,
          left: 60,
          child: _buildFloatingIcon(Icons.verified_user_rounded, delay: 3000),
        ),
        Positioned(
          bottom: 150,
          right: 80,
          child: _buildFloatingIcon(Icons.event_available_rounded, delay: 4500),
        ),
      ],
    );
  }

  Widget _buildFloatingBlob({required Color color, required double size, required int delay}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .move(
       begin: const Offset(0, -20), 
       end: const Offset(0, 20), 
       duration: 4000.ms, 
       curve: Curves.easeInOutSine, 
       delay: delay.ms
     )
     .then()
     .move(
       begin: const Offset(0, 20), 
       end: const Offset(0, -20), 
       duration: 4000.ms, 
       curve: Curves.easeInOutSine
     );
  }

  Widget _buildFloatingIcon(IconData icon, {required int delay}) {
    return Icon(
      icon,
      color: const Color(0xFF3F51B5).withOpacity(0.06),
      size: 40,
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .moveY(begin: -15, end: 15, duration: 3000.ms, curve: Curves.easeInOutSine, delay: delay.ms)
     .rotate(begin: -0.05, end: 0.05, duration: 4000.ms, curve: Curves.easeInOut);
  }
}
