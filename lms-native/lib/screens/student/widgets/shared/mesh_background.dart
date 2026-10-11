import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class MeshBackground extends StatelessWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background blobs
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4F46E5).withOpacity(0.12),
            ),
          ).animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
           .scaleXY(begin: 1.0, end: 1.3, duration: 5.seconds, curve: Curves.easeInOut),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF38BDF8).withOpacity(0.12),
            ),
          ).animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
           .scaleXY(begin: 1.2, end: 1.0, duration: 4.seconds, curve: Curves.easeInOut),
        ),
        Positioned(
          top: 300,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0EA5E9).withOpacity(0.1),
            ),
          ).animate(onPlay: (AnimationController controller) => controller.repeat(reverse: true))
           .scaleXY(begin: 1.0, end: 1.15, curve: Curves.easeInOut, duration: 6.seconds)
           .moveX(begin: 0, end: -40, duration: 6.seconds),
        ),
        
        // Glass effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: const SizedBox(),
          ),
        ),

        // Foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}
