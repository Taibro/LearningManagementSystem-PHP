import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/admin/users/admin_users_bloc.dart';
import '../../../../blocs/admin/users/admin_users_state.dart';
import '../../../../models/admin/admin_teacher.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import 'users_helpers.dart';
import 'bottom_sheets/user_detail_sheet.dart';
import 'bottom_sheets/user_form_sheet.dart';

class LecturersTab extends StatefulWidget {
  const LecturersTab({super.key});

  @override
  State<LecturersTab> createState() => _LecturersTabState();
}

class _LecturersTabState extends State<LecturersTab> {
  String _lecturerSearch = '';
  String _lecturerFilter = 'Tất cả';
  static const _kPrimary = Color(0xFF1A237E);

  List<AdminTeacher> _getFilteredLecturers(List<AdminTeacher> teachers) {
    return teachers.where((l) {
      final q = _lecturerSearch.toLowerCase();
      final matchSearch = q.isEmpty ||
          (l.fullName?.toLowerCase().contains(q) ?? false) ||
          (l.teacherCode?.toLowerCase().contains(q) ?? false);
      
      final mockStatus = 'active'; // Mặc định vì API chưa có
      final matchFilter = _lecturerFilter == 'Tất cả' ||
          (_lecturerFilter == 'Hoạt động' && mockStatus == 'active') ||
          (_lecturerFilter == 'Nghỉ' && mockStatus == 'inactive');
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Tất cả', 'Hoạt động', 'Nghỉ'];
    return Column(children: [
      buildSearchBar(
          'Tìm giảng viên, mã GV...', (v) => setState(() => _lecturerSearch = v)),
      buildFilterRow(
          filters, _lecturerFilter, (f) => setState(() => _lecturerFilter = f)),
      Expanded(
        child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersLoading) {
              return const Center(child: CustomLoadingIndicator());
            } else if (state is AdminUsersLoadSuccess) {
              final filtered = _getFilteredLecturers(state.teachers);
              if (filtered.isEmpty) {
                return const Center(
                    child: Text('Không tìm thấy giảng viên',
                        style: TextStyle(color: Color(0xFF9E9E9E))));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _lecturerCard(filtered[i]),
              );
            } else if (state is AdminUsersLoadFailure) {
              return Center(
                  child: Text('Lỗi: ${state.error}',
                      style: const TextStyle(color: Colors.red)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    ]);
  }

  Widget _lecturerCard(AdminTeacher l) {
    final isActive = true; // API chưa trả về status, mặc định active
    final statusColor = isActive ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E);
    return GestureDetector(
      onTap: () => _showUserDetailSheet(l),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          buildAvatarWidget(
              (l.fullName ?? 'U').split(' ').last.substring(0, 1),
              [const Color(0xFF00695C), const Color(0xFF2E7D32)]),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(l.fullName ?? 'Không tên',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(l.teacherCode ?? '',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E))),
                ]),
                const SizedBox(height: 2),
                Text('Chưa rõ học vị  ·  Chưa rõ ngạch  ·  ${l.departmentName ?? 'Khoa chưa phân'}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 6),
                Row(children: [
                  buildChipWidget(isActive ? 'Đang dạy' : 'Nghỉ', statusColor),
                  const SizedBox(width: 8),
                  Icon(Icons.class_outlined, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 3),
                  const Text('0 lớp',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E))),
                ]),
              ])),
          PopupMenuButton<String>(
            onSelected: (v) => _handleAction(v, l),
            itemBuilder: (_) => [
              buildPopupItem('detail', Icons.info_outline, 'Xem chi tiết', null),
              buildPopupItem('edit', Icons.edit_outlined, 'Chỉnh sửa', null),
              buildPopupItem('classes', Icons.class_outlined, 'Phân công lớp', null),
              buildPopupItem('reset', Icons.lock_reset, 'Đặt lại MK', null),
            ],
            icon: const Icon(Icons.more_vert,
                color: Color(0xFF9E9E9E), size: 20),
          ),
        ]),
      ),
    );
  }

  void _handleAction(String action, AdminTeacher user) {
    if (action == 'detail') {
      _showUserDetailSheet(user);
    } else if (action == 'edit') {
      _showUserFormSheet(user);
    } else {
      _snack('$action: ${user.fullName}');
    }
  }

  void _showUserDetailSheet(AdminTeacher user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserDetailSheet(user: {'name': user.fullName, 'code': user.teacherCode, 'status': 'active'}, type: 'lecturer'),
    );
  }

  void _showUserFormSheet(AdminTeacher user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserFormSheet(user: {'name': user.fullName, 'code': user.teacherCode}, type: 'lecturer'),
    );
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: _kPrimary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2)),
      );
}
