import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/lecturer/statistic/teacher_statistic_bloc.dart';
import '../../blocs/lecturer/statistic/teacher_statistic_event.dart';
import '../../blocs/lecturer/statistic/teacher_statistic_state.dart';
import '../../models/lecturer/teaching_statistic.dart';

const Color _kPrimary = Color(0xFF6B4FA0);
const Color _kBg = Color(0xFFF8F9FA);

class LecturerTeachingStatsScreen extends StatefulWidget {
  const LecturerTeachingStatsScreen({super.key});

  @override
  State<LecturerTeachingStatsScreen> createState() => _LecturerTeachingStatsScreenState();
}

class _LecturerTeachingStatsScreenState extends State<LecturerTeachingStatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherStatisticBloc>().add(TeacherStatisticFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Thống kê giảng dạy'),
          Expanded(
            child: BlocBuilder<TeacherStatisticBloc, TeacherStatisticState>(
              builder: (context, state) {
                if (state is TeacherStatisticLoading || state is TeacherStatisticInitial) {
                  return const Center(
                    child: CustomLoadingIndicator(),
                  );
                } else if (state is TeacherStatisticLoadFailure) {
                  return Center(
                    child: Text(
                      'Lỗi: ${state.message}',
                      style: GoogleFonts.inter(color: Colors.redAccent),
                    ),
                  );
                } else if (state is TeacherStatisticLoadSuccess) {
                  final stat = state.statistic;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng quan học kỳ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ).animate().fadeIn().slideX(begin: -0.1),
                        const SizedBox(height: 16),
                        _buildSummaryRow(stat).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                        const SizedBox(height: 32),

                        Text(
                          'Tiến độ theo tháng',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                        const SizedBox(height: 16),
                        _buildMonthlyChart(stat).animate().fadeIn(delay: 300.ms).scale(curve: Curves.easeOutQuart),
                        const SizedBox(height: 32),

                        Text(
                          'Thống kê chi tiết',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                        const SizedBox(height: 16),
                        _buildStatsGrid(stat).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                        const SizedBox(height: 32),

                        Text(
                          'Danh sách môn học',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                        const SizedBox(height: 16),
                        _buildDetailTable(stat).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(TeachingStatistic stat) {
    final items = [
      {'value': '${stat.totalPeriods ?? 0}', 'label': 'Tổng tiết\nđã dạy', 'color': _kPrimary, 'icon': Icons.timer_outlined},
      {'value': '${stat.examShifts ?? 0}', 'label': 'Buổi\ncoi thi', 'color': const Color(0xFFE85D75), 'icon': Icons.event_available_outlined},
      {'value': '${stat.overallProgress ?? 0}%', 'label': 'Tiến độ\ngiảng dạy', 'color': const Color(0xFF2E7D32), 'icon': Icons.trending_up_rounded},
    ];

    return Row(
      children: items.map((item) {
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  item['value'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyChart(TeachingStatistic stat) {
    final maxPeriods = stat.chartData != null && stat.chartData!.isNotEmpty
        ? stat.chartData!.map((e) => e.periods ?? 0).fold<int>(0, (max, val) => val > max ? val : max)
        : 1;

    final months = stat.chartData?.map((e) {
          final val = e.periods ?? 0;
          return {
            'month': e.month ?? '',
            'value': maxPeriods > 0 ? val / maxPeriods : 0.0,
            'realValue': val,
          };
        }).toList() ?? [];

    if (months.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: const Center(
          child: Text('Chưa có dữ liệu thống kê tháng', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

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
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: months.map((m) {
                final ratio = m['value'] as double;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${m['realValue']}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
                          ),
                        ).animate().fade(delay: 500.ms),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.elasticOut,
                          height: 120 * ratio,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9F7AEA), Color(0xFF6B4FA0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B4FA0).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          m['month'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(TeachingStatistic stat) {
    final stats = [
      {'label': 'Tổng tiết đã dạy', 'value': '${stat.totalPeriods ?? 0} tiết', 'color': _kPrimary, 'icon': Icons.library_books},
      {'label': 'Tiết lý thuyết', 'value': '${stat.theoryPeriods ?? 0} tiết', 'color': const Color(0xFF3B82F6), 'icon': Icons.menu_book_rounded},
      {'label': 'Tiết thực hành', 'value': '${stat.labPeriods ?? 0} tiết', 'color': const Color(0xFFF59E0B), 'icon': Icons.computer_rounded},
      {'label': 'Tỷ lệ lý thuyết', 'value': '${stat.theoryPercentage ?? 0}%', 'color': const Color(0xFFEC4899), 'icon': Icons.pie_chart_rounded},
      {'label': 'Số buổi coi thi', 'value': '${stat.examShifts ?? 0} buổi', 'color': const Color(0xFFE85D75), 'icon': Icons.fact_check_rounded},
      {'label': 'Sắp tới', 'value': '${stat.upcomingExamShifts ?? 0} ca thi', 'color': const Color(0xFF10B981), 'icon': Icons.next_plan_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.0,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) {
        final s = stats[i];
        final color = s['color'] as Color;
        final icon = s['icon'] as IconData;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s['value'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTable(TeachingStatistic stat) {
    final data = stat.classDetails ?? [];

    if (data.isEmpty) {
      return const Center(child: Text('Không có dữ liệu chi tiết lớp học.'));
    }

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Môn học', style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w700))),
                Expanded(flex: 2, child: Text('Lớp', style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Đã dạy', style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Tổng', style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
              ],
            ),
          ),
          ...data.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            final isLast = i == data.length - 1;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      d.subjectName ?? '',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d.classCode ?? '',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${d.completedPeriods ?? 0}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: _kPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${d.totalPeriods ?? 0}',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
