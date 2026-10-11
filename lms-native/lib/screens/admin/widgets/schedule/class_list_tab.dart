import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/admin/class/admin_class_bloc.dart';
import '../../../../blocs/admin/class/admin_class_state.dart';
import '../../../../models/admin/admin_class.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import 'bottom_sheets/class_form_sheet.dart';
import 'bottom_sheets/change_room_sheet.dart';
import '../../data/mock_admin_schedule_data.dart' show mockRooms;

class ClassListTab extends StatefulWidget {
  const ClassListTab({super.key});

  @override
  State<ClassListTab> createState() => _ClassListTabState();
}

class _ClassListTabState extends State<ClassListTab> {
  String _scheduleFilter = 'Tất cả';
  String _scheduleSearch = '';
  static const _kPrimary = Color(0xFF1A237E);

  List<AdminClass> _getFilteredClasses(List<AdminClass> classes) {
    return classes.where((c) {
      // Vì API không trả về type, ta giả lập logic filter
      final q = _scheduleSearch.toLowerCase();
      final matchSearch = q.isEmpty ||
          (c.courseName?.toLowerCase().contains(q) ?? false) ||
          (c.code?.toLowerCase().contains(q) ?? false);
      return matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildClassFilter(),
      Expanded(
        child: BlocBuilder<AdminClassBloc, AdminClassState>(
          builder: (context, state) {
            if (state is AdminClassLoading) {
              return const Center(child: CustomLoadingIndicator());
            } else if (state is AdminClassLoadSuccess) {
              final filtered = _getFilteredClasses(state.classes);
              if (filtered.isEmpty) {
                return const Center(
                    child: Text('Không tìm thấy lớp học',
                        style: TextStyle(color: Color(0xFF9E9E9E))));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildClassCard(filtered[i]),
              );
            } else if (state is AdminClassLoadFailure) {
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

  Widget _buildClassFilter() {
    final filters = ['Tất cả', 'Lý thuyết', 'Thực hành', 'Trực tuyến'];
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Tìm môn học, giảng viên, nhóm lớp...',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _kPrimary.withOpacity(0.3), width: 1.5)),
          ),
          style: const TextStyle(fontSize: 13),
          onChanged: (v) => setState(() => _scheduleSearch = v),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: filters.map((f) {
            final sel = _scheduleFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _scheduleFilter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _kPrimary : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? _kPrimary : Colors.transparent),
                    boxShadow: sel ? [BoxShadow(color: _kPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                  ),
                  child: Text(f, style: TextStyle(fontSize: 12, color: sel ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }).toList()),
        ),
      ]),
    );
  }

  Widget _buildClassCard(AdminClass c) {
    Color col = const Color(0xFF2E7D32);
    Color bg = const Color(0xFFE8F5E9);
    
    final enrolled = c.enrolledStudents ?? 0;
    final capacity = c.maxStudents ?? 0;
    final ratio = capacity > 0 ? enrolled / capacity : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: col, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(13),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(6)),
            child: Text(
                'LT',
                style: TextStyle(
                    fontSize: 10, color: col, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(c.courseName ?? 'Chưa xác định',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF212121)))),
          PopupMenuButton<String>(
            onSelected: (v) => _handleClassAction(v, c),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Chỉnh sửa')
                  ])),
              const PopupMenuItem(
                  value: 'room',
                  child: Row(children: [
                    Icon(Icons.meeting_room_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Đổi phòng')
                  ])),
              const PopupMenuItem(
                  value: 'cancel',
                  child: Row(children: [
                    Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Huỷ lịch', style: TextStyle(color: Colors.red))
                  ])),
            ],
            icon: const Icon(Icons.more_vert,
                color: Color(0xFF9E9E9E), size: 20),
          ),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 14, runSpacing: 4, children: [
          _infoChip(Icons.person_outlined, 'Chưa xếp'),
          _infoChip(Icons.group_outlined, c.code ?? 'Chưa có mã'),
          _infoChip(Icons.location_on_outlined, 'Chưa xếp'),
          _infoChip(Icons.access_time_outlined, 'Chưa xếp'),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sĩ số: $enrolled/$capacity',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9E9E9E))),
                      Text('${(ratio * 100).toInt()}%',
                          style: TextStyle(
                              fontSize: 11,
                              color: col,
                              fontWeight: FontWeight.bold)),
                    ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: const Color(0xFFE8E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(col),
                      minHeight: 5),
                ),
              ])),
        ]),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: const Color(0xFF9E9E9E)),
      const SizedBox(width: 3),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF616161))),
    ]);
  }

  void _handleClassAction(String action, AdminClass c) {
    if (action == 'edit') _showEditClassSheet(c);
    if (action == 'room') _showChangeRoomSheet(c);
    if (action == 'cancel') _showCancelConfirm(c);
  }

  void _showEditClassSheet(AdminClass c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClassFormSheet(existing: null), // Update to accept AdminClass if needed later
    );
  }

  void _showChangeRoomSheet(AdminClass c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeRoomSheet(rooms: mockRooms, currentClass: {}), // Update later
    );
  }

  void _showCancelConfirm(AdminClass c) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Huỷ lớp học',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Text(
                  'Xác nhận huỷ lớp "${c.courseName}" - ${c.code}?',
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF616161))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Không',
                        style: TextStyle(color: Color(0xFF616161)))),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('Huỷ'),
                ),
              ],
            ));
  }
}
