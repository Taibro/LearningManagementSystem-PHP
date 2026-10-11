import 'package:flutter/material.dart';

class LecturerCustomAppBar extends StatelessWidget {
  final String title;
  final IconData? icon;

  const LecturerCustomAppBar({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A3570), Color(0xFF6B4FA0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: canPop ? 4 : 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
            )
          else if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          Expanded(
            child: Text(
              title,
              textAlign: canPop || icon == null ? TextAlign.center : TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (canPop) const SizedBox(width: 48),
        ],
      ),
    );
  }
}
