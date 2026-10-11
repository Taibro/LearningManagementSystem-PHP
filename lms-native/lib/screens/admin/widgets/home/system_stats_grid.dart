import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../models/admin/dashboard_stats.dart';

class SystemStatsGrid extends StatelessWidget {
  final DashboardStats stats;
  const SystemStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = [
      {'label': 'Sinh viên',   'value': '${stats.totalStudents ?? 0}', 'icon': Icons.school_outlined,       'color': const Color(0xFF1A237E)},
      {'label': 'Giảng viên',  'value': '${stats.totalTeachers ?? 0}',   'icon': Icons.person_outlined,        'color': const Color(0xFF2E7D32)},
      {'label': 'Lớp học phần','value': '${stats.totalClasses ?? 0}',   'icon': Icons.class_outlined,         'color': const Color(0xFFE65100)},
      {'label': 'Vắng hôm nay',   'value': '${stats.todayAbsences ?? 0}',    'icon': Icons.meeting_room_outlined,  'color': const Color(0xFFE85D75)},
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) {
        final c = cards[i];
        final col = c['color'] as Color;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: col.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: col.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(c['icon'] as IconData, color: col, size: 24),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c['value'] as String,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: col,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      c['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
