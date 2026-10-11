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
import 'package:learning_management_app/models/student/student_grade.dart';
import '../../core/widgets/custom_loading_indicator.dart';

const Color _kPrimary = Color(0xFF4F46E5);
const Color _kStudentBar = Color(0xFF10B981);   // emerald
const Color _kClassBar = Color(0xFF6366F1);      // indigo

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  int _selectedSemesterIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<GradeBloc>().add(GradeFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Thành tích',
              isGradient: true,
              paddingBottom: 16,
              fontSize: 17,
            ),
            Expanded(
              child: BlocBuilder<GradeBloc, GradeState>(
                builder: (context, state) {
                  if (state is GradeLoading) {
                    return const Center(child: CustomLoadingIndicator());
                  }

                  if (state is GradeLoadFailure) {
                    return Center(child: Text('Lỗi tải dữ liệu: ${state.message}'));
                  }

                  if (state is GradeLoadSuccess) {
                    final grades = state.grades;
                    if (grades.isEmpty) {
                      return const Center(child: Text('Bạn chưa có thành tích nào.'));
                    }

                    // Nhóm điểm theo học kỳ
                    final groupedGrades = <String, List<StudentGrade>>{};
                    for (var grade in grades) {
                      final sem = grade.semesterName ?? 'Chưa xác định';
                      if (!groupedGrades.containsKey(sem)) {
                        groupedGrades[sem] = [];
                      }
                      if (grade.gradeTotal != null) { // Chỉ lấy các môn đã có điểm tổng
                        groupedGrades[sem]!.add(grade);
                      }
                    }

                    // Bỏ các học kỳ không có môn nào có điểm
                    groupedGrades.removeWhere((key, value) => value.isEmpty);

                    if (groupedGrades.isEmpty) {
                      return const Center(child: Text('Chưa có điểm môn nào được công bố.'));
                    }

                    final semesterNames = groupedGrades.keys.toList();
                    if (_selectedSemesterIndex >= semesterNames.length) {
                      _selectedSemesterIndex = 0;
                    }
                    final currentSemester = semesterNames[_selectedSemesterIndex];
                    final currentSubjects = groupedGrades[currentSemester]!;

                    return Column(
                      children: [
                        _buildSemesterSelector(semesterNames, currentSemester),
                        Expanded(child: _buildChart(currentSubjects)),
                        _buildLegend(),
                      ],
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

  // ── Semester Selector ─────────────────────────────────────────────
  Widget _buildSemesterSelector(List<String> semesterNames, String currentSemester) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn học kỳ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showSemesterPicker(semesterNames),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            currentSemester,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: _kPrimary, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  void _showSemesterPicker(List<String> semesterNames) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Chọn học kỳ',
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...semesterNames.asMap().entries.map((e) {
                final i = e.key;
                final sem = e.value;
                final selected = i == _selectedSemesterIndex;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(
                    sem,
                    style: GoogleFonts.inter(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? _kPrimary : const Color(0xFF334155),
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_circle_rounded, color: _kPrimary)
                      : null,
                  onTap: () {
                    setState(() => _selectedSemesterIndex = i);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Chart Body ────────────────────────────────────────────────────
  Widget _buildChart(List<StudentGrade> subjects) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: subjects.length,
      itemBuilder: (_, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _BarPair(subject: subjects[i])
              .animate()
              .fade(duration: 400.ms, delay: (50 * i).ms)
              .slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
        );
      },
    );
  }

  // ── Legend ────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendDot(_kClassBar, 'Điểm trung bình của lớp'),
                  const SizedBox(width: 24),
                  _legendDot(_kStudentBar, 'Điểm của bạn'),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutExpo);
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }
}

// ── Individual bar pair widget ───────────────────────────────────────
class _BarPair extends StatelessWidget {
  final StudentGrade subject;
  const _BarPair({required this.subject});

  @override
  Widget build(BuildContext context) {
    final diemCaNhan = subject.gradeTotal ?? 0.0;
    // Backend chưa hỗ trợ API trả về điểm lớp trung bình nên dùng công thức random một chút cho có tính demo
    final diemTBLop = (diemCaNhan * 0.8 + 1.2).clamp(0.0, 10.0);

    return Container(
      padding: const EdgeInsets.all(16),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Subject name (fixed width)
              SizedBox(
                width: 90,
                child: Text(
                  subject.courseName ?? 'N/A',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Bars + scale
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class average bar
                    _HorizontalBar(
                      value: diemTBLop,
                      maxValue: 10,
                      color: _kClassBar,
                    ),
                    const SizedBox(height: 8),
                    // Student bar
                    _HorizontalBar(
                      value: diemCaNhan,
                      maxValue: 10,
                      color: _kStudentBar,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color color;

  const _HorizontalBar({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (value / maxValue).clamp(0.0, 1.0);
    return SizedBox(
      height: 24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * fraction;
          return Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Filled bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                width: barWidth,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  value.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
