import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/admin/users/admin_users_bloc.dart';
import '../../../../blocs/admin/users/admin_users_state.dart';
import '../../../../models/admin/admin_student.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import 'users_helpers.dart';
import 'bottom_sheets/user_detail_sheet.dart';
import 'bottom_sheets/user_form_sheet.dart';

class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  String _studentSearch = '';
  String _studentFilter = 'Tất cả';
  static const _kPrimary = Color(0xFF1A237E);

  List<AdminStudent> _getFilteredStudents(List<AdminStudent> students) {
    return students.where((s) {
      final q = _studentSearch.toLowerCase();
      final matchSearch = q.isEmpty ||
          (s.fullName?.toLowerCase().contains(q) ?? false) ||
          (s.studentCode?.contains(q) ?? false);
      
      // Giả lập filter trạng thái vì API chưa có
      final mockStatus = 'active'; // Mặc định là active
      final matchFilter = _studentFilter == 'Tất cả' ||
          (_studentFilter == 'Hoạt động' && mockStatus == 'active') ||
          (_studentFilter == 'Cảnh báo' && mockStatus == 'warning') ||
          (_studentFilter == 'Khoá' && mockStatus == 'locked');
      
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Tất cả', 'Hoạt động', 'Cảnh báo', 'Khoá'];
    return Column(children: [
      buildSearchBar(
          'Tìm sinh viên, MSSV...', (v) => setState(() => _studentSearch = v)),
      buildFilterRow(
          filters, _studentFilter, (f) => setState(() => _studentFilter = f)),
      Expanded(
        child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
          builder: (context, state) {
            if (state is AdminUsersLoading) {
              return const Center(child: CustomLoadingIndicator());
            } else if (state is AdminUsersLoadSuccess) {
              final filtered = _getFilteredStudents(state.students);
              if (filtered.isEmpty) {
                return const Center(
                    child: Text('Không tìm thấy sinh viên',
                        style: TextStyle(color: Color(0xFF9E9E9E))));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _studentCard(filtered[i]),
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

  Widget _studentCard(AdminStudent s) {
    Color statusColor = const Color(0xFF4CAF50);
    String statusLabel = 'Hoạt động';
    
    final gpa = 0.0; // Giả lập GPA
    final gpaColor = const Color(0xFFC62828);

    return GestureDetector(
      onTap: () => _showUserDetailSheet(s),
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
              (s.fullName ?? 'U').split(' ').last.substring(0, 1),
              [_kPrimary.withOpacity(0.7), _kPrimary]),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(s.fullName ?? 'Không tên',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${s.studentCode ?? 'Không MSSV'}  ·  ${s.className ?? 'Chưa xếp lớp'}  ·  ${s.major ?? 'Chưa xếp ngành'}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9E9E9E))),
                const SizedBox(height: 6),
                Row(children: [
                  buildChipWidget(statusLabel, statusColor),
                  const SizedBox(width: 8),
                  buildChipWidget('GPA: $gpa', gpaColor),
                ]),
              ])),
          PopupMenuButton<String>(
            onSelected: (v) => _handleAction(v, s),
            itemBuilder: (_) => [
              buildPopupItem('detail', Icons.info_outline, 'Xem chi tiết', null),
              buildPopupItem('edit', Icons.edit_outlined, 'Chỉnh sửa', null),
              buildPopupItem('reset', Icons.lock_reset, 'Đặt lại MK', null),
              buildPopupItem('lock', Icons.block, 'Khoá TK', Colors.red),
            ],
            icon: const Icon(Icons.more_vert,
                color: Color(0xFF9E9E9E), size: 20),
          ),
        ]),
      ),
    );
  }

  void _handleAction(String action, AdminStudent user) {
    if (action == 'detail') {
      _showUserDetailSheet(user);
    } else if (action == 'edit') {
      _showUserFormSheet(user);
    } else {
      _snack('$action: ${user.fullName}');
    }
  }

  void _showUserDetailSheet(AdminStudent user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserDetailSheet(user: {'name': user.fullName, 'mssv': user.studentCode, 'status': 'active', 'gpa': 0.0}, type: 'student'),
    );
  }

  void _showUserFormSheet(AdminStudent user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserFormSheet(user: {'name': user.fullName, 'mssv': user.studentCode}, type: 'student'),
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
