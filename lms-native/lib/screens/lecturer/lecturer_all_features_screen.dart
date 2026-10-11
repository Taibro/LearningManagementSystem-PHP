import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lecturer_attendance_screen.dart';
import 'lecturer_teaching_stats_screen.dart';
import 'lecturer_salary_screen.dart';
import 'lecturer_materials_screen.dart';
import 'lecturer_request_screen.dart';
import 'lecturer_personal_profile_screen.dart';
import 'lecturer_survey_screen.dart';
import 'lecturer_schedule_screen.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

const Color _kPrimary = Color(0xFF6B4FA0);
const Color _kBg = Color(0xFFF8F9FA);

class LecturerAllFeaturesScreen extends StatelessWidget {
  const LecturerAllFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        icon: Icons.how_to_reg_rounded,
        label: 'Điểm danh',
        color: _kPrimary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerAttendanceScreen(initialTabIndex: 0)),
        ),
      ),
      _Feature(
        icon: Icons.qr_code_2_rounded,
        label: 'QR Code',
        color: const Color(0xFF10B981),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerAttendanceScreen(initialTabIndex: 1)),
        ),
      ),
      _Feature(
        icon: Icons.grade_rounded,
        label: 'Kết quả\nhọc tập',
        color: const Color(0xFF3B82F6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerAttendanceScreen(initialTabIndex: 2)),
        ),
      ),
      _Feature(
        icon: Icons.bar_chart_rounded,
        label: 'Thống kê\ngiảng dạy',
        color: const Color(0xFFF59E0B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerTeachingStatsScreen()),
        ),
      ),
      _Feature(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Thông tin\nlương',
        color: const Color(0xFF2E7D32),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerSalaryScreen()),
        ),
      ),
      _Feature(
        icon: Icons.library_books_rounded,
        label: 'Tài liệu\nbài giảng',
        color: const Color(0xFF5C6BC0),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerMaterialsScreen()),
        ),
      ),
      _Feature(
        icon: Icons.edit_document,
        label: 'Đề xuất\nlịch dạy',
        color: const Color(0xFFEC4899),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerRequestScreen()),
        ),
      ),
      _Feature(
        icon: Icons.badge_rounded,
        label: 'Hồ sơ\ncá nhân',
        color: const Color(0xFF5C6BC0),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerPersonalProfileScreen()),
        ),
      ),
      _Feature(
        icon: Icons.poll_rounded,
        label: 'Khảo sát',
        color: const Color(0xFFE85D75),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerSurveyScreen()),
        ),
      ),
      _Feature(
        icon: Icons.calendar_month_rounded,
        label: 'Lịch dạy',
        color: const Color(0xFFE65100),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const LecturerScheduleScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Tất cả tính năng'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B4FA0).withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: features.length,
                  itemBuilder: (_, i) {
                    final f = features[i];
                    return GestureDetector(
                      onTap: f.onTap,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: f.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: f.color.withOpacity(0.15), width: 1.5),
                            ),
                            child: Icon(f.icon, color: f.color, size: 28),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              f.label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(delay: (i * 50).ms, curve: Curves.easeOutBack, duration: 400.ms);
                  },
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Feature({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
