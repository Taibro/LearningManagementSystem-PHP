import 'package:flutter/material.dart';
import 'dart:ui';

Widget buildSummaryCard(String value, String label, Color color) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5)),
              ),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B), height: 1.3)),
            ]),
          ),
        ),
      ),
    ),
  );
}

Widget buildSectionCard(String title, IconData icon, Widget content) {
  const kPrimary = Color(0xFF3F51B5);
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: kPrimary.withOpacity(0.08),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: kPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.5)),
            ]),
            const SizedBox(height: 20),
            content,
          ]),
        ),
      ),
    ),
  );
}
