import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../blocs/admin/reports/admin_reports_bloc.dart';
import '../../../../blocs/admin/reports/admin_reports_state.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../data/mock_admin_reports_data.dart';
import 'reports_helpers.dart';

class AttendanceTab extends StatelessWidget {
  const AttendanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReportsBloc, AdminReportsState>(
      builder: (context, state) {
        if (state is AdminReportsLoading) {
          return const Center(child: CustomLoadingIndicator());
        } else if (state is AdminReportsLoadSuccess) {
          final stats = state.stats;
          final classes = state.classes;
          final random = Random(42); // Fixed seed for mock data

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(children: [
              // Summary
              Row(children: [
                buildSummaryCard('96.2%', 'Tỉ lệ đi học TB', const Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                buildSummaryCard('${stats.todayAbsences}', 'SV vắng mặt h.nay', const Color(0xFFE85D75)),
                const SizedBox(width: 8),
                buildSummaryCard('${stats.totalClasses}', 'Tổng số lớp', const Color(0xFF3F51B5)),
              ]).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
              // By class
              buildSectionCard(
                'Tỉ lệ điểm danh theo lớp học phần',
                Icons.class_outlined,
                Column(
                  children: classes.take(10).toList().asMap().entries.map((entry) {
                    final idx = entry.key;
                    final s = entry.value;
                    // Giả lập số lượng sinh viên và điểm danh
                    final total = s.enrolledStudents ?? 40;
                    final present = total > 0 ? (total * (0.8 + random.nextDouble() * 0.2)).round() : 0;
                    final pct = total > 0 ? present / total : 0.0;
                    final col = pct >= 0.95
                        ? const Color(0xFF4CAF50)
                        : pct >= 0.85
                            ? const Color(0xFFE65100)
                            : const Color(0xFFC62828);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: col.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: col.withOpacity(0.1)),
                      ),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${s.code ?? ''} – ${s.courseName ?? ''}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            const Text('Chưa phân công', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('${(pct * 100).toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: col)),
                            Text('$present/$total SV', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          ]),
                        ]),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: col.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(col),
                            minHeight: 8,
                          ),
                        ),
                      ]),
                    ).animate().fade(delay: (200 + idx * 100).ms).slideX(begin: 0.1, end: 0);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Warning students
              buildSectionCard(
                'Sinh viên vắng quá 20%',
                Icons.warning_amber_rounded,
                Column(
                  children: mockWarningStudents.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final s = entry.value;
                    return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC62828).withOpacity(0.15)),
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFC62828).withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text('${s['mssv']}  ·  Vắng ${s['absent']}/${s['total']} buổi', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ])),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(20), boxShadow: [
                              BoxShadow(color: const Color(0xFFC62828).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))
                            ]),
                            child: Text('${s['pct']}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ).animate().fade(delay: (400 + idx * 100).ms).slideY(begin: 0.1, end: 0);
                  }).toList(),
                ),
              ),
            ]),
          );
        } else if (state is AdminReportsLoadFailure) {
          return Center(
              child: Text('Lỗi: ${state.error}', style: const TextStyle(color: Colors.red)));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
