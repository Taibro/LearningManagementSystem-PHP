import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'widgets/shared/custom_app_bar.dart';
import 'widgets/shared/mesh_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import '../../blocs/student/attendance/attendance_bloc.dart';
import '../../blocs/student/attendance/attendance_event.dart';
import '../../blocs/student/attendance/attendance_state.dart';
import '../../models/student/student_attendance.dart';

const Color _kPrimary = Color(0xFF4F46E5);

class AttendanceStatsScreen extends StatefulWidget {
  const AttendanceStatsScreen({super.key});

  @override
  State<AttendanceStatsScreen> createState() => _AttendanceStatsScreenState();
}

class _AttendanceStatsScreenState extends State<AttendanceStatsScreen> {
  String? _expandedSemester;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(AttendanceFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Thống kê điểm danh'),
            _buildTableHeader(),
            Expanded(
              child: BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) {
                  if (state is AttendanceLoading) {
                    return Center(child: CustomLoadingIndicator());
                  } else if (state is AttendanceLoadFailure) {
                    return Center(child: Text('Lỗi: ${state.message}'));
                  } else if (state is AttendanceLoadSuccess) {
                    final attendances = state.attendances;
                    if (attendances.isEmpty) {
                      return const Center(child: Text('Chưa có dữ liệu điểm danh'));
                    }

                    final grouped = <String, List<StudentAttendance>>{};
                    for (var a in attendances) {
                      final sem = a.semesterName ?? 'Chưa xác định';
                      grouped.putIfAbsent(sem, () => []).add(a);
                    }

                    if (_expandedSemester == null && grouped.isNotEmpty) {
                      _expandedSemester = grouped.keys.last;
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: grouped.length,
                      itemBuilder: (_, i) {
                        final semName = grouped.keys.elementAt(i);
                        final semAttendances = grouped[semName]!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _SemesterSection(
                            semesterName: semName,
                            attendances: semAttendances,
                            isExpanded: _expandedSemester == semName,
                            onToggle: () {
                              setState(() {
                                _expandedSemester = _expandedSemester == semName ? null : semName;
                              });
                            },
                          ).animate().fade(duration: 400.ms, delay: (50 * i).ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text('Mã môn', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
              ),
              Expanded(
                child: Center(
                  child: Text('Tên môn', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                ),
              ),
              SizedBox(
                width: 42,
                child: Center(
                  child: Text('DVHT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                ),
              ),
              SizedBox(
                width: 30,
                child: Center(
                  child: Text('CP', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                ),
              ),
              SizedBox(
                width: 30,
                child: Center(
                  child: Text('KP', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}

class _SemesterSection extends StatelessWidget {
  final String semesterName;
  final List<StudentAttendance> attendances;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SemesterSection({
    required this.semesterName,
    required this.attendances,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    int totalDvht = attendances.fold(0, (sum, a) => sum + (a.credits ?? 0));
    int totalCp = attendances.fold(0, (sum, a) => sum + (a.absentWithPermission ?? 0));
    int totalKp = attendances.fold(0, (sum, a) => sum + (a.absentWithoutPermission ?? 0));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Semester header row
              GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: isExpanded ? _kPrimary.withOpacity(0.1) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: isExpanded ? _kPrimary : const Color(0xFF64748B),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          semesterName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isExpanded ? _kPrimary : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 42,
                        child: Center(
                          child: Text(
                            '$totalDvht',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isExpanded ? _kPrimary : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Center(
                          child: Text(
                            '$totalCp',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Center(
                          child: Text(
                            '$totalKp',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: totalKp > 0 ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
              // Subject rows (if expanded)
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Column(
                  children: attendances.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final sub = entry.value;
                    final kp = sub.absentWithoutPermission ?? 0;

                    return Container(
                      decoration: BoxDecoration(
                        border: idx < attendances.length - 1
                            ? Border(bottom: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.5), width: 1))
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(
                              sub.classCode ?? '',
                              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                sub.courseName ?? '',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0F172A), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 42,
                            child: Center(
                              child: Text(
                                '${sub.credits ?? 0}',
                                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Center(
                              child: Text(
                                '${sub.absentWithPermission ?? 0}',
                                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Center(
                              child: Text(
                                '$kp',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: kp > 0 ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                  fontWeight: kp > 0 ? FontWeight.w700 : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
