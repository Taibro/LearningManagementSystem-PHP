import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/student/profile/profile_bloc.dart';
import '../../blocs/student/profile/profile_event.dart';
import '../../blocs/student/profile/profile_state.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import 'data/mock_extra_data.dart';
import 'widgets/shared/custom_app_bar.dart';
import 'widgets/shared/mesh_background.dart';

const Color _kPrimary = Color(0xFF4F46E5);

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileFetchRequested());
    for (int i = 0; i < kCurriculum.semesters.length; i++) {
      final sem = kCurriculum.semesters[i];
      final hasInProgress = sem.categories.any((c) =>
          c.subjects.any((s) => s.trangThai == SubjectStatus.inProgress));
      if (hasInProgress) {
        _expandedIndex = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Chương trình khung'),
            _buildStudentInfo(),
            _buildTableHeader(),
            Expanded(child: _buildSemesterList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CustomLoadingIndicator());
        }
        
        String chuyenNganh = 'Đang cập nhật...';
        String nganh = 'Đang cập nhật...';
        String heDaoTao = 'Đại học'; // Default
        String loaiDaoTao = 'Chính quy'; // Default

        if (state is ProfileLoadSuccess) {
          final profile = state.profile;
          chuyenNganh = profile.major ?? 'Chưa xác định';
          nganh = profile.departmentName ?? 'Chưa xác định';
          // Hệ đào tạo và loại hình hiện tại backend chưa có field rõ ràng, nên ta có thể fix cứng hoặc suy luận
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chuyên ngành',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chuyenNganh,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Ngành: ', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                      Expanded(
                        child: Text(nganh,
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('Hệ đào tạo: ', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                      Text(heDaoTao,
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                      const SizedBox(width: 24),
                      Text('Loại: ', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                      Text(loaiDaoTao,
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuart);
      },
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
              Expanded(
                flex: 4,
                child: Text('Tên học phần',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
              ),
              SizedBox(
                width: 80,
                child: Center(
                  child: Text('Mã HP',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                ),
              ),
              SizedBox(
                width: 30,
                child: Center(
                  child: Text('TC',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                ),
              ),
              SizedBox(
                width: 44,
                child: Center(
                  child: Text('T.Thái',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildSemesterList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: kCurriculum.semesters.length,
      itemBuilder: (_, i) {
        final sem = kCurriculum.semesters[i];
        final isExpanded = _expandedIndex == i;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _SemesterBlock(
            semester: sem,
            isExpanded: isExpanded,
            onToggle: () {
              setState(() {
                _expandedIndex = _expandedIndex == i ? -1 : i;
              });
            },
          ).animate().fade(duration: 400.ms, delay: (50 * i).ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
        );
      },
    );
  }
}

class _SemesterBlock extends StatelessWidget {
  final CurriculumSemester semester;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SemesterBlock({
    required this.semester,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
              // Semester header
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
                          semester.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isExpanded ? _kPrimary : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExpanded ? _kPrimary : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${semester.totalTC} TC',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isExpanded ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Expanded content
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Column(
                  children: semester.categories.expand((cat) => [
                    // Category header
                    Container(
                      color: _kPrimary.withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              cat.label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '${cat.totalTC} TC',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Subject rows
                    ...cat.subjects.map((sub) => _SubjectRow(subject: sub)),
                  ]).toList(),
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

class _SubjectRow extends StatelessWidget {
  final CurriculumSubject subject;
  const _SubjectRow({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.5), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              subject.tenHocPhan,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0F172A), fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 80,
            child: Center(
              child: Text(
                subject.maHP,
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Center(
              child: Text(
                '${subject.tinChi}',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569), fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Center(child: _statusIcon(subject.trangThai)),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon(SubjectStatus status) {
    switch (status) {
      case SubjectStatus.completed:
        return const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22);
      case SubjectStatus.inProgress:
        return const Icon(Icons.incomplete_circle_rounded, color: Color(0xFFF59E0B), size: 22);
      case SubjectStatus.notStarted:
        return const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFFCBD5E1), size: 22);
    }
  }
}
