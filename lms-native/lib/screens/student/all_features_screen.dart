import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'academic_result_screen.dart';
import 'achievement_screen.dart';
import 'attendance_stats_screen.dart';
import 'features_screens/conduct_screen.dart';
import 'features_screens/survey_screen.dart';
import 'features_screens/news_screen.dart';
import 'features_screens/student_teacher_list_screen.dart';
import 'curriculum_screen.dart';
import 'receipt_screen.dart';
import 'schedule_screen.dart';
import 'widgets/payment_bottom_sheet.dart';
import 'widgets/shared/custom_app_bar.dart';
import 'widgets/shared/mesh_background.dart';

class AllFeaturesScreen extends StatelessWidget {
  const AllFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        icon: Icons.grade_rounded,
        label: 'Xem điểm',
        color: const Color(0xFF4F46E5),
        bgColor: const Color(0xFF4F46E5).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AcademicResultScreen()),
        ),
      ),
      _Feature(
        icon: Icons.monetization_on_rounded,
        label: 'Thanh toán\nhọc phí',
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFF10B981).withOpacity(0.1),
        onTap: () {
          Navigator.pop(context);
          PaymentBottomSheet.show(context);
        },
      ),
      _Feature(
        icon: Icons.stars_rounded,
        label: 'Thành tích',
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFF59E0B).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AchievementScreen()),
        ),
      ),
      _Feature(
        icon: Icons.receipt_long_rounded,
        label: 'Phiếu thu\ntổng hợp',
        color: const Color(0xFF06B6D4),
        bgColor: const Color(0xFF06B6D4).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReceiptScreen()),
        ),
      ),
      _Feature(
        icon: Icons.menu_book_rounded,
        label: 'Chương trình\nkhung',
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFEF4444).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CurriculumScreen()),
        ),
      ),
      _Feature(
        icon: Icons.calendar_month_rounded,
        label: 'Lịch học/\nlịch thi',
        color: const Color(0xFFF97316),
        bgColor: const Color(0xFFF97316).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScheduleScreen()),
        ),
      ),
      _Feature(
        icon: Icons.how_to_reg_rounded,
        label: 'Thống kê\nđiểm danh',
        color: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFF8B5CF6).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AttendanceStatsScreen()),
        ),
      ),
      _Feature(
        icon: Icons.emoji_events_rounded,
        label: 'Rèn luyện',
        color: const Color(0xFFEAB308),
        bgColor: const Color(0xFFEAB308).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConductScreen()),
        ),
      ),
      _Feature(
        icon: Icons.article_rounded,
        label: 'Tin tức',
        color: const Color(0xFF3B82F6),
        bgColor: const Color(0xFF3B82F6).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewsScreen()),
        ),
      ),
      _Feature(
        icon: Icons.poll_rounded,
        label: 'Khảo sát',
        color: const Color(0xFF14B8A6),
        bgColor: const Color(0xFF14B8A6).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SurveyScreen()),
        ),
      ),
      _Feature(
        icon: Icons.chat_rounded,
        label: 'Trò chuyện',
        color: const Color(0xFFE11D48),
        bgColor: const Color(0xFFE11D48).withOpacity(0.1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentTeacherListScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Tất cả tính năng',
              isGradient: true,
              paddingBottom: 24,
              fontSize: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Padding(
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
                                      color: f.bgColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                                    ),
                                    child: Icon(f.icon, color: f.color, size: 28),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    f.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fade(duration: 400.ms, delay: (40 * i).ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
                          },
                        ),
                      ),
                    ),
                  ),
                ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _Feature({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}
