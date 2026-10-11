import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../blocs/admin/reports/admin_reports_bloc.dart';
import '../../../../blocs/admin/reports/admin_reports_state.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../data/mock_admin_reports_data.dart';
import 'reports_helpers.dart';

class GradesTab extends StatelessWidget {
  const GradesTab({super.key});

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF3F51B5);

    return BlocBuilder<AdminReportsBloc, AdminReportsState>(
      builder: (context, state) {
        if (state is AdminReportsLoading) {
          return const Center(child: CustomLoadingIndicator());
        } else if (state is AdminReportsLoadSuccess) {
          final stats = state.stats;
          final classes = state.classes;
          final random = Random(42);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(children: [
              Row(children: [
                buildSummaryCard('7.4', 'Điểm TB toàn trường', kPrimary),
                const SizedBox(width: 8),
                buildSummaryCard('92%', 'Tỉ lệ đạt', const Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                buildSummaryCard('${stats.totalStudents}', 'Tổng sinh viên', const Color(0xFFE65100)),
              ]).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
              buildSectionCard(
                'Phân bố kết quả học tập',
                Icons.bar_chart_rounded,
                Column(
                  children: mockDistribution.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final d = entry.value;
                    final col = d['color'] as Color;
                    // Phân bổ ngẫu nhiên dựa trên tổng sinh viên
                    final totalStudents = stats.totalStudents ?? 0;
                    final count = (totalStudents * (d['pct'] as double)).round();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: col.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: col.withOpacity(0.1)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(d['label'].toString().substring(0, 1), style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 16))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(d['label'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                              Text('$count SV  (${((d['pct'] as double) * 100).toInt()}%)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: col)),
                            ]),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: d['pct'] as double,
                                backgroundColor: col.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(col),
                                minHeight: 8,
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ).animate().fade(delay: (200 + idx * 100).ms).slideX(begin: 0.1, end: 0);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              buildSectionCard(
                'Lớp có điểm TB cao nhất',
                Icons.emoji_events_rounded,
                Column(
                  children: classes.take(3).toList().asMap().entries.map((e) {
                    final idx = e.key;
                    final c = e.value;
                    final medals = ['🥇', '🥈', '🥉'];
                    // Giả lập điểm trung bình cao cho top 3
                    final avg = (8.5 - idx * 0.4 + random.nextDouble() * 0.2).toStringAsFixed(1);
                    final passed = 100 - random.nextInt(10); // 90-100%

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kPrimary.withOpacity(0.08)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                          ),
                          child: Text(medals[idx], style: const TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${c.code ?? ''} – ${c.courseName ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text('Đạt: $passed%', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Text('ĐTB: $avg', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    ).animate().fade(delay: (400 + idx * 100).ms).slideY(begin: 0.1, end: 0);
                  }).toList(),
                ),
              ),
            ]),
          );
        } else if (state is AdminReportsLoadFailure) {
          return Center(child: Text('Lỗi: ${state.error}', style: const TextStyle(color: Colors.red)));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
