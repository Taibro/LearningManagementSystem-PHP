import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../blocs/lecturer/profile/teacher_profile_bloc.dart';
import '../../../../../blocs/lecturer/profile/teacher_profile_state.dart';
import '../../../../../blocs/lecturer/statistic/teacher_statistic_bloc.dart';
import '../../../../../blocs/lecturer/statistic/teacher_statistic_state.dart';
import 'shared_sheet_helpers.dart';

class DeclarationSheet extends StatelessWidget {
  const DeclarationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          buildSheetHandle(),
          buildSheetHeader('Khai báo thông tin', 'Học kỳ hiện tại', const Color(0xFFF59E0B), icon: Icons.assignment_rounded),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<TeacherProfileBloc, TeacherProfileState>(
                builder: (context, profileState) {
                  return BlocBuilder<TeacherStatisticBloc, TeacherStatisticState>(
                    builder: (context, statState) {
                      String fullName = 'Chưa cập nhật';
                      String teacherCode = 'Chưa cập nhật';
                      String department = 'Chưa cập nhật';
                      String totalPeriods = '0';
                      String totalClasses = '0';

                      if (profileState is TeacherProfileLoadSuccess) {
                        fullName = profileState.profile.fullName ?? fullName;
                        teacherCode = profileState.profile.teacherCode ?? teacherCode;
                        department = profileState.profile.departmentName ?? department;
                      }

                      if (statState is TeacherStatisticLoadSuccess) {
                        totalPeriods = '${statState.statistic.totalPeriods ?? 0}';
                        totalClasses = '${statState.statistic.classDetails?.length ?? 0}';
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Họ và tên', fullName, Icons.person_rounded, readOnly: true),
                          const SizedBox(height: 16),
                          _buildInfoRow('Mã giảng viên', teacherCode, Icons.badge_rounded, readOnly: true),
                          const SizedBox(height: 16),
                          _buildInfoRow('Khoa / Bộ môn', department, Icons.business_rounded, readOnly: true),
                          const SizedBox(height: 16),
                          _buildInfoRow('Học kỳ khai báo', 'Học kỳ hiện tại', Icons.date_range_rounded),
                          const SizedBox(height: 16),
                          _buildInfoRow('Số tiết dạy dự kiến', totalPeriods, Icons.timer_rounded),
                          const SizedBox(height: 16),
                          _buildInfoRow('Số lớp phụ trách', totalClasses, Icons.class_rounded),
                          const SizedBox(height: 16),
                          const Text('Ghi chú', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Không có ghi chú đặc biệt.',
                              style: TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Đã lưu khai báo thành công!'),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B4FA0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('LƯU KHAI BÁO', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
            border: Border.all(color: readOnly ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: readOnly ? const Color(0xFF94A3B8) : const Color(0xFF6B4FA0)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: readOnly ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
