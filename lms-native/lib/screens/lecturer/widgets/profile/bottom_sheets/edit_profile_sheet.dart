import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../blocs/lecturer/profile/teacher_profile_bloc.dart';
import '../../../../../blocs/lecturer/profile/teacher_profile_state.dart';
import 'shared_sheet_helpers.dart';

class EditProfileSheet extends StatelessWidget {
  const EditProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          buildSheetHandle(),
          buildSheetHeader(
              'Thông tin giảng viên', 'Chỉ đọc', const Color(0xFF6B4FA0)),
          Expanded(
            child: BlocBuilder<TeacherProfileBloc, TeacherProfileState>(
              builder: (context, state) {
                if (state is TeacherProfileLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TeacherProfileLoadSuccess) {
                  final profile = state.profile;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildProfileRow('Họ và tên', profile.fullName ?? 'Chưa cập nhật'),
                        _buildProfileRow('Mã giảng viên', profile.teacherCode ?? 'Chưa cập nhật'),
                        _buildProfileRow('Khoa / Bộ môn', profile.departmentName ?? 'Chưa cập nhật'),
                        _buildProfileRow('Học hàm / Học vị', profile.degree ?? 'Chưa cập nhật'),
                        _buildProfileRow('Email công vụ', profile.email ?? 'Chưa cập nhật'),
                        _buildProfileRow('Điện thoại', profile.phone ?? 'Chưa cập nhật'),
                        _buildProfileRow('Chuyên ngành', profile.specialization ?? 'Chưa cập nhật'),
                      ],
                    ),
                  );
                } else if (state is TeacherProfileLoadFailure) {
                  return Center(
                    child: Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)),
                  );
                }
                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF9E9E9E))),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121))),
          ),
        ],
      ),
    );
  }
}
