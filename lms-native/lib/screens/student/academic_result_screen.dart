import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'widgets/shared/custom_app_bar.dart';
import 'widgets/shared/mesh_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student/grade/grade_bloc.dart';
import '../../blocs/student/grade/grade_event.dart';
import '../../blocs/student/grade/grade_state.dart';
import '../../blocs/student/profile/profile_bloc.dart';
import '../../blocs/student/profile/profile_event.dart';
import '../../blocs/student/profile/profile_state.dart';
import 'package:learning_management_app/models/student/student_grade.dart';
import '../../core/widgets/custom_loading_indicator.dart';

const Color _kPrimary = Color(0xFF1565C0);
const Color _kBg = Color(0xFFF0F4FF);

class AcademicResultScreen extends StatefulWidget {
  const AcademicResultScreen({super.key});

  @override
  State<AcademicResultScreen> createState() => _AcademicResultScreenState();
}

class _AcademicResultScreenState extends State<AcademicResultScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GradeBloc>().add(GradeFetchRequested());
    context.read<ProfileBloc>().add(ProfileFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: MeshBackground(
          child: Column(
            children: [
              const CustomAppBar(
                title: 'Kết quả học tập',
                isGradient: true,
                paddingBottom: 16,
                fontSize: 17,
              ),
              _buildTabBar(),
              const Expanded(
                child: TabBarView(
                  children: [
                    _OverviewTab(),
                    _SummaryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.transparent,
      child: TabBar(
        labelColor: _kPrimary,
        unselectedLabelColor: const Color(0xFF94A3B8),
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
        indicatorColor: _kPrimary,
        indicatorWeight: 3,
        dividerColor: const Color(0xFFE2E8F0).withOpacity(0.5),
        tabs: const [
          Tab(text: 'Tổng quan'),
          Tab(text: 'Tổng kết'),
        ],
      ),
    );
  }
}

// ── Tab 1: Tổng quan ─────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<GradeBloc, GradeState>(
          builder: (context, gradeState) {
            if (profileState is ProfileLoading || gradeState is GradeLoading) {
              return const Center(child: CustomLoadingIndicator());
            }

            if (profileState is ProfileLoadFailure) {
              return Center(child: Text('Lỗi tải thông tin: ${profileState.message}'));
            }
            if (gradeState is GradeLoadFailure) {
              return Center(child: Text('Lỗi tải điểm: ${gradeState.message}'));
            }

            if (profileState is ProfileLoadSuccess && gradeState is GradeLoadSuccess) {
              final profile = profileState.profile;
              final grades = gradeState.grades;

              // Calculate stats
              int stcDaDangKy = 0;
              int stcDaTichLuy = 0;
              double sumDiem10 = 0.0;
              double sumDiem4 = 0.0;
              int stcTinhDiem = 0;

              for (var g in grades) {
                final tinChi = g.credits ?? 0;
                stcDaDangKy += tinChi;
                
                if (g.gradeTotal != null) {
                  final diem10 = g.gradeTotal!;
                  stcTinhDiem += tinChi;
                  sumDiem10 += diem10 * tinChi;
                  
                  // Convert hệ 4
                  double diem4 = 0.0;
                  if (diem10 >= 8.5) diem4 = 4.0;
                  else if (diem10 >= 8.0) diem4 = 3.5;
                  else if (diem10 >= 7.0) diem4 = 3.0;
                  else if (diem10 >= 6.5) diem4 = 2.5;
                  else if (diem10 >= 5.5) diem4 = 2.0;
                  else if (diem10 >= 5.0) diem4 = 1.5;
                  else if (diem10 >= 4.0) diem4 = 1.0;
                  
                  sumDiem4 += diem4 * tinChi;

                  if (diem10 >= 4.0) {
                    stcDaTichLuy += tinChi;
                  }
                }
              }

              double tbc10 = stcTinhDiem > 0 ? sumDiem10 / stcTinhDiem : 0.0;
              double tbc4 = stcTinhDiem > 0 ? sumDiem4 / stcTinhDiem : 0.0;
              
              int stcNo = stcDaDangKy - stcDaTichLuy;
              if (stcNo < 0) stcNo = 0;
              double percentNo = stcDaDangKy > 0 ? (stcNo / stcDaDangKy) * 100 : 0.0;
              
              final nienKhoa = profile.enrollmentYear != null ? '${profile.enrollmentYear} - ${profile.enrollmentYear! + 4}' : 'Chưa xác định';
              final namHoc = profile.enrollmentYear != null ? DateTime.now().year - profile.enrollmentYear! : 1;

              final rows = [
                _InfoRow('Họ tên', profile.fullName ?? 'N/A'),
                _InfoRow('Sinh viên năm', '${namHoc > 0 ? namHoc : 1}'),
                _InfoRow('Niên khóa', nienKhoa),
                _InfoRow('Thời gian đào tạo', '4.0'),
                _InfoRow('Điểm TBC tích lũy (hệ 4)', tbc4.toStringAsFixed(2)),
                _InfoRow('Điểm TBC tích lũy (hệ 10)', tbc10.toStringAsFixed(2)),
                _InfoRow('STC đã đăng ký', '$stcDaDangKy'),
                _InfoRow('STC đã tích lũy', '$stcDaTichLuy'),
                _InfoRow('%STC nợ', '$stcNo (${percentNo.toStringAsFixed(2)}%)'),
                _InfoRow('STC phải tích lũy', '151.00'), // Fixed for now
              ];

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => Divider(height: 1, indent: 20, endIndent: 20, color: const Color(0xFFE2E8F0).withOpacity(0.5)),
                        itemBuilder: (_, i) {
                          final row = rows[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    row.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                const Text(' : ', style: TextStyle(color: Color(0xFF94A3B8))),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    row.value,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
              );
            }

            return const SizedBox();
          },
        );
      },
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GradeBloc, GradeState>(
      builder: (context, state) {
        if (state is GradeLoading) {
          return Center(child: CustomLoadingIndicator());
        } else if (state is GradeLoadFailure) {
          return Center(child: Text('Lỗi: ${state.message}'));
        } else if (state is GradeLoadSuccess) {
          final grades = state.grades;
          if (grades.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu điểm'));
          }

          // Nhóm điểm theo học kỳ
          final groupedGrades = <String, List<StudentGrade>>{};
          for (var grade in grades) {
            final sem = grade.semesterName ?? 'Chưa xác định';
            if (!groupedGrades.containsKey(sem)) {
              groupedGrades[sem] = [];
            }
            groupedGrades[sem]!.add(grade);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedGrades.length,
            itemBuilder: (_, i) {
              final semesterName = groupedGrades.keys.elementAt(i);
              final semesterGrades = groupedGrades[semesterName]!;
              return _SemesterBlock(semesterName: semesterName, grades: semesterGrades);
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _SemesterBlock extends StatelessWidget {
  final String semesterName;
  final List<StudentGrade> grades;
  
  const _SemesterBlock({required this.semesterName, required this.grades});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Semester header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            semesterName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4F46E5),
            ),
          ),
        ),

        // Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  // Header row
                  Container(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 60, child: Text('Mã môn', style: _kTableHeader)),
                        Expanded(child: Text('Môn Học', style: _kTableHeader)),
                        SizedBox(width: 36, child: Text('TC', style: _kTableHeader, textAlign: TextAlign.center)),
                        SizedBox(width: 60, child: Text('Điểm TB', style: _kTableHeader, textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  // Data rows
                  ...grades.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final sub = entry.value;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.5), width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(sub.courseCode ?? 'N/A', style: _kTableCell),
                          ),
                          Expanded(
                            child: Text(sub.courseName ?? 'N/A', style: _kTableCell.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF0F172A))),
                          ),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${sub.credits ?? 0}',
                              style: _kTableCell,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              sub.gradeTotal != null ? sub.gradeTotal!.toStringAsFixed(1) : '-',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: sub.gradeTotal != null ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),

        const SizedBox(height: 24),
      ],
    );
  }
}

final TextStyle _kTableHeader = GoogleFonts.inter(
  color: const Color(0xFF4F46E5),
  fontSize: 12,
  fontWeight: FontWeight.w700,
);

final TextStyle _kTableCell = GoogleFonts.inter(
  fontSize: 12,
  color: const Color(0xFF64748B),
);
