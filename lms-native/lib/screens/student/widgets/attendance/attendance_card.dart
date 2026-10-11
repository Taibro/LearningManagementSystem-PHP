import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning_management_app/core/enum/AttendanceStatus.dart';
import 'package:learning_management_app/models/Attendance.dart';
import 'attendance_method_sheet.dart';

class AttendanceCard extends StatelessWidget {
  final Attendance item;
  final VoidCallback onAttendanceSuccess;

  const AttendanceCard({
    super.key,
    required this.item,
    required this.onAttendanceSuccess,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData statusIcon;

    switch (item.status) {
      case AttendanceStatus.chuaDiemDanh:
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFFEF3C7);
        statusText = 'Chưa điểm danh';
        statusIcon = Icons.pending_actions_rounded;
        break;
      case AttendanceStatus.daDiemDanh:
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFD1FAE5);
        statusText = 'Đã điểm danh';
        statusIcon = Icons.check_circle_rounded;
        break;
      case AttendanceStatus.vang:
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        statusText = 'Vắng mặt';
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Color(0xFF4F46E5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subjectName,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _infoRow(Icons.access_time_filled_rounded, 'Tiết:', item.tiet),
                const SizedBox(height: 8),
                _infoRow(Icons.class_rounded, 'Lớp:', item.lop),
                const SizedBox(height: 8),
                _infoRow(Icons.meeting_room_rounded, 'Phòng:', item.phong),
              ],
            ),
          ),
          if (item.status == AttendanceStatus.chuaDiemDanh) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openAttendanceSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fingerprint_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Điểm danh ngay',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().shimmer(duration: 2.seconds, delay: 1.seconds),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
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

  void _openAttendanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AttendanceMethodSheet(item: item, onSuccess: onAttendanceSuccess),
    );
  }
}
