import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/lecturer/statistic/teacher_statistic_bloc.dart';
import '../../../../blocs/lecturer/statistic/teacher_statistic_state.dart';
import '../../../../models/lecturer/teaching_statistic.dart';

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherStatisticBloc, TeacherStatisticState>(
      builder: (context, state) {
        if (state is TeacherStatisticLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6B4FA0)));
        }
        
        List<ClassTeachingDetail> classDetails = [];
        String currentSemester = 'HK2 - 2025-2026';
        if (state is TeacherStatisticLoadSuccess) {
          classDetails = state.statistic.classDetails ?? [];
          currentSemester = state.statistic.currentSemesterLabel ?? currentSemester;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          child: Column(
            children: [
              _buildProgressFilter(currentSemester).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 20),
              if (classDetails.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              else
                ...classDetails.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildProgressCard(entry.value)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: (50 * entry.key).ms)
                          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressFilter(String currentSemester) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(currentSemester,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4FA0), Color(0xFF8B6BBF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B4FA0).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Xem tiến độ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(ClassTeachingDetail item) {
    final done = item.completedPeriods ?? 0;
    final total = item.totalPeriods ?? 0;
    final pct = total > 0 ? done / total : 0.0;
    final pctString = item.progressPercentage ?? (pct * 100).toInt();
    
    // Choose color based on progress
    Color statusColor;
    String status;
    if (pct == 1) {
      statusColor = const Color(0xFF10B981);
      status = 'Hoàn thành';
    } else if (pct > 0) {
      statusColor = const Color(0xFF3B82F6);
      status = 'Đang dạy';
    } else {
      statusColor = const Color(0xFFF59E0B);
      status = 'Chưa bắt đầu';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.class_rounded, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subjectName ?? 'Môn học',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.classCode ?? 'Mã lớp',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ).animate().slideX(begin: -0.2, end: 0, duration: 800.ms, curve: Curves.easeOutQuart),
              ),
              const SizedBox(width: 16),
              Text(
                '$pctString%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ).animate().scale(duration: 400.ms, delay: 200.ms, curve: Curves.easeOutBack),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã dạy: $done tiết',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              Text(
                'Còn lại: ${total - done} tiết',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
