import 'package:flutter/material.dart';
import 'dart:ui';

Widget buildHomeCard({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF3F51B5).withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        )
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    ),
  );
}

Widget buildSectionTitle(String title, IconData icon) {
  const kPrimary = Color(0xFF3F51B5);
  return Row(children: [
    Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: kPrimary, size: 16),
    ),
    const SizedBox(width: 12),
    Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E293B),
        letterSpacing: -0.5,
      ),
    ),
  ]);
}
