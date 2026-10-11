import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning_management_app/core/enum/ScheduleType.dart';
import 'package:learning_management_app/models/Schedule.dart';
import '../../data/mock_schedule_data.dart';
import '../../utils/schedule_utils.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule item;

  const ScheduleCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final baseColor = typeColor(item.type);
    
    // Create a gradient based on the base color
    final colorHSL = HSLColor.fromColor(baseColor);
    final lightColor = colorHSL.withLightness((colorHSL.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    final darkColor = colorHSL.withLightness((colorHSL.lightness - 0.1).clamp(0.0, 1.0)).toColor();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored gradient left accent
            Container(
              width: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [lightColor, darkColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.subjectName,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: const Color(0xFF0F172A),
                              height: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.type == ScheduleType.lichThi ? 'Lịch thi' : 'Lịch học',
                            style: GoogleFonts.inter(
                              color: darkColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow(Icons.access_time_filled_rounded, 'Tiết:', item.tiet),
                    const SizedBox(height: 6),
                    _infoRow(Icons.meeting_room_rounded, 'Phòng:', item.phong),
                    const SizedBox(height: 6),
                    _infoRow(Icons.person_rounded, 'Giảng viên:', item.giangVien),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}
