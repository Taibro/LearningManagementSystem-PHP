import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/stats_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/lecturer/statistic/teacher_statistic_bloc.dart';
import '../../../../blocs/lecturer/statistic/teacher_statistic_state.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherStatisticBloc, TeacherStatisticState>(
      builder: (context, state) {
        String examShifts = '0';
        String reminders = '0';
        String progress = '0%';

        if (state is TeacherStatisticLoadSuccess) {
          final stats = state.statistic;
          examShifts = '${stats.examShifts ?? 0}';
          reminders = '${stats.reminders?.length ?? 0}';
          progress = '${stats.overallProgress ?? 0}%';
        }

        return Row(
          children: [
            _buildStatCard(context, 'Gác thi', examShifts, Icons.assignment_outlined, const Color(0xFF6B4FA0), 0)
                .animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(width: 12),
            _buildStatCard(context, 'Nhắc nhở', reminders, Icons.notifications_active_outlined, const Color(0xFF4CAF50), 1)
                .animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(width: 12),
            _buildStatCard(context, 'Tiến độ', progress, Icons.trending_up_rounded, const Color(0xFFE85D75), 2)
                .animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color, int tabIndex) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatsDetailScreen(initialTabIndex: tabIndex),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
