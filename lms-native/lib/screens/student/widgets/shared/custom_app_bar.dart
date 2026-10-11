import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final bool isGradient;
  final double paddingBottom;
  final double fontSize;
  final Widget? trailing;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isGradient = false,
    this.paddingBottom = 14,
    this.fontSize = 18,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.5), width: 1.0)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: paddingBottom,
      ),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              textAlign: canPop || trailing != null ? TextAlign.center : TextAlign.left,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F172A),
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing! else SizedBox(width: canPop ? 48 : 16),
        ],
      ),
    );
  }
}
