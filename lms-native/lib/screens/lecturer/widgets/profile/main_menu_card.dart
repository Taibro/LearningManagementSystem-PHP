import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../lecturer_salary_screen.dart';
import '../../lecturer_teaching_stats_screen.dart';
import 'package:learning_management_app/screens/lecturer/features/salary_info_screen.dart';
import 'package:learning_management_app/screens/lecturer/features/teaching_stats_screen.dart';
import 'bottom_sheets/declaration_sheet.dart';
import 'bottom_sheets/salary_sheet.dart';
import '../../lecturer_personal_profile_screen.dart';
import '../../lecturer_materials_screen.dart';
import '../../lecturer_survey_screen.dart';

class MainMenuCard extends StatelessWidget {
  const MainMenuCard({super.key});



  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showDeclarationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeclarationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.badge_rounded,
              iconBgColor: const Color(0xFF4F46E5).withOpacity(0.08),
              iconColor: const Color(0xFF4F46E5),
              label: 'Hồ sơ cá nhân',
              subtitle: 'Thông tin giảng viên',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LecturerPersonalProfileScreen()),
              ),
              index: 0,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.monetization_on_rounded,
              iconBgColor: const Color(0xFF10B981).withOpacity(0.08),
              iconColor: const Color(0xFF10B981),
              label: 'Thông tin lương',
              subtitle: 'Xem bảng lương theo tháng',
              onTap: () => _navigateTo(context, const LecturerSalaryScreen()),
              index: 1,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.assignment_rounded,
              iconBgColor: const Color(0xFFF59E0B).withOpacity(0.08),
              iconColor: const Color(0xFFF59E0B),
              label: 'Khai báo thông tin',
              subtitle: 'Cập nhật thông tin giảng dạy HK',
              onTap: () => _showDeclarationSheet(context),
              index: 2,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.library_books_rounded,
              iconBgColor: const Color(0xFF6B4FA0).withOpacity(0.08),
              iconColor: const Color(0xFF6B4FA0),
              label: 'Quản lý tài liệu bài giảng',
              subtitle: 'Tải lên và quản lý giáo án',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LecturerMaterialsScreen()),
              ),
              index: 3,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.bar_chart_rounded,
              iconBgColor: const Color(0xFF3B82F6).withOpacity(0.08),
              iconColor: const Color(0xFF3B82F6),
              label: 'Thống kê thực giảng, coi thi',
              subtitle: 'Tổng hợp giờ giảng, giờ coi thi',
              onTap: () => _navigateTo(context, const LecturerTeachingStatsScreen()),
              index: 4,
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.poll_rounded,
              iconBgColor: const Color(0xFFE85D75).withOpacity(0.08),
              iconColor: const Color(0xFFE85D75),
              label: 'Khảo sát',
              subtitle: 'Lấy ý kiến sinh viên về môn học',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LecturerSurveyScreen()),
              ),
              index: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    required int index,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: iconColor.withOpacity(0.05),
        splashColor: iconColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withOpacity(0.1), width: 1),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 24),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildDivider() => const Divider(
        height: 1,
        thickness: 1,
        indent: 80,
        endIndent: 20,
        color: Color(0xFFF1F5F9),
      );
}
