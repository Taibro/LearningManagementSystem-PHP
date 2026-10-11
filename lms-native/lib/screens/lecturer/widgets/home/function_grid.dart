import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning_management_app/core/utils/feature_manager.dart';
import '../../lecturer_attendance_screen.dart';
import '../../lecturer_teaching_stats_screen.dart';
import '../../lecturer_salary_screen.dart';
import '../../lecturer_materials_screen.dart';
import '../../lecturer_request_screen.dart';
import '../../lecturer_all_features_screen.dart';
import '../../lecturer_customize_features_screen.dart';
import '../../lecturer_personal_profile_screen.dart';
import '../../lecturer_survey_screen.dart';
import '../../lecturer_schedule_screen.dart';
import '../../features_screens/lecturer_chat_list_screen.dart';

class FunctionGrid extends StatefulWidget {
  const FunctionGrid({super.key});

  @override
  State<FunctionGrid> createState() => _FunctionGridState();
}

class _FunctionGridState extends State<FunctionGrid> {
  late List<Map<String, dynamic>> _allFeatures;
  List<Map<String, dynamic>> _displayFeatures = [];

  @override
  void initState() {
    super.initState();
    _initFeatures();
    _loadDisplayFeatures();
  }

  void navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _initFeatures() {
    _allFeatures = [
      {
        'icon': Icons.how_to_reg_rounded,
        'label': 'Điểm danh',
        'color': const Color(0xFF6B4FA0),
        'onTap': () => navigateTo(const LecturerAttendanceScreen(initialTabIndex: 0)),
      },
      {
        'icon': Icons.qr_code_2_rounded,
        'label': 'QR Code',
        'color': const Color(0xFF10B981),
        'onTap': () => navigateTo(const LecturerAttendanceScreen(initialTabIndex: 1)),
      },
      {
        'icon': Icons.grade_rounded,
        'label': 'Kết quả học tập',
        'color': const Color(0xFF3B82F6),
        'onTap': () => navigateTo(const LecturerAttendanceScreen(initialTabIndex: 2)),
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Thống kê giảng dạy',
        'color': const Color(0xFFF59E0B),
        'onTap': () => navigateTo(const LecturerTeachingStatsScreen()),
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'Thông tin lương',
        'color': const Color(0xFF2E7D32),
        'onTap': () => navigateTo(const LecturerSalaryScreen()),
      },
      {
        'icon': Icons.library_books_rounded,
        'label': 'Tài liệu bài giảng',
        'color': const Color(0xFF5C6BC0),
        'onTap': () => navigateTo(const LecturerMaterialsScreen()),
      },
      {
        'icon': Icons.edit_document,
        'label': 'Đề xuất lịch dạy',
        'color': const Color(0xFFEC4899),
        'onTap': () => navigateTo(const LecturerRequestScreen()),
      },
      {
        'icon': Icons.badge_rounded,
        'label': 'Hồ sơ cá nhân',
        'color': const Color(0xFF5C6BC0),
        'onTap': () => navigateTo(const LecturerPersonalProfileScreen()),
      },
      {
        'icon': Icons.poll_rounded,
        'label': 'Khảo sát',
        'color': const Color(0xFFE85D75),
        'onTap': () => navigateTo(const LecturerSurveyScreen()),
      },
      {
        'icon': Icons.calendar_month_rounded,
        'label': 'Lịch dạy',
        'color': const Color(0xFFE65100),
        'onTap': () => navigateTo(const LecturerScheduleScreen()),
      },
      {
        'icon': Icons.chat_bubble_rounded,
        'label': 'Trò chuyện',
        'color': const Color(0xFF1E88E5),
        'onTap': () => navigateTo(const LecturerChatListScreen()),
      },
      {
        'icon': Icons.grid_view_rounded,
        'label': 'Tất cả',
        'color': const Color(0xFF6B4FA0),
        'onTap': () => navigateTo(const LecturerAllFeaturesScreen()),
      },
    ];
  }

  void _loadDisplayFeatures() {
    final manager = FeatureManager();
    final savedHome = manager.getHomeFeatureIds('lecturer');

    if (savedHome == null) {
      _displayFeatures = _allFeatures.where((f) => [
        'Điểm danh', 'QR Code', 'Kết quả học tập', 'Thống kê giảng dạy',
        'Thông tin lương', 'Tài liệu bài giảng', 'Đề xuất lịch dạy', 'Trò chuyện'
      ].contains(f['label']) || f['label'] == 'Tất cả').toList();
    } else {
      _displayFeatures = savedHome
          .map((label) => _allFeatures.firstWhere((f) => f['label'] == label, orElse: () => _allFeatures.first))
          .toList();
      if (!_displayFeatures.any((f) => f['label'] == 'Tất cả')) {
        _displayFeatures.add(_allFeatures.firstWhere((f) => f['label'] == 'Tất cả'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tiện ích',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: -0.3,
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LecturerCustomizeFeaturesScreen()),
                );
                setState(() {
                  _loadDisplayFeatures();
                });
              },
              icon: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF64748B)),
              label: const Text(
                'Tuỳ chỉnh',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B4FA0).withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: _displayFeatures.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 20,
              childAspectRatio: 0.65,
            ),
            itemCount: _displayFeatures.length,
            itemBuilder: (context, index) {
              final item = _displayFeatures[index];
              return _buildGridItem(
                context: context,
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                color: item['color'] as Color,
                onTap: () {
                  final fn = item['onTap'] as VoidCallback;
                  fn();
                },
                index: index,
              );
            },
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildGridItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.15), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().scale(
      duration: 300.ms,
      delay: (50 * index).ms,
      curve: Curves.easeOutBack,
    );
  }
}
