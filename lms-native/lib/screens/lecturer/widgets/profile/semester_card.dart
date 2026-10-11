import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/lecturer/statistic/teacher_statistic_bloc.dart';
import '../../../../blocs/lecturer/statistic/teacher_statistic_state.dart';

class SemesterCard extends StatelessWidget {
  const SemesterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4FA0).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6B4FA0).withOpacity(0.1), width: 1),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFF6B4FA0), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Học kỳ hiện tại',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tiến độ giảng dạy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đang diễn ra',
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<TeacherStatisticBloc, TeacherStatisticState>(
            builder: (context, state) {
              if (state is TeacherStatisticLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TeacherStatisticLoadSuccess) {
                final stats = state.statistic;
                final totalClasses = stats.classDetails?.length ?? 0;
                final totalPeriods = stats.totalPeriods ?? 0;
                final completedPeriods = stats.classDetails?.fold<int>(0, (sum, c) => sum + (c.completedPeriods ?? 0)) ?? 0;
                final remainingPeriods = (totalPeriods - completedPeriods) > 0 ? (totalPeriods - completedPeriods) : 0;
                final progress = totalPeriods > 0 ? completedPeriods / totalPeriods : 0.0;
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSemStat('$totalClasses', 'Lớp dạy'),
                        _buildSemStat('$totalPeriods', 'Tổng tiết'),
                        _buildSemStat('$completedPeriods', 'Đã dạy', color: const Color(0xFF10B981)),
                        _buildSemStat('$remainingPeriods', 'Còn lại', color: const Color(0xFFF59E0B)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B4FA0)),
                        minHeight: 8,
                      ),
                    ).animate().slideX(begin: -0.2, end: 0, duration: 800.ms, curve: Curves.easeOutQuart),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đã hoàn thành ${(progress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$completedPeriods/$totalPeriods tiết',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (state is TeacherStatisticLoadFailure) {
                return Center(
                  child: Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSemStat(String value, String label, {Color color = const Color(0xFF6B4FA0)}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
