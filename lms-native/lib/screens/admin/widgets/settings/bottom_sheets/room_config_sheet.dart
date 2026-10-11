import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../blocs/admin/settings/room/admin_room_bloc.dart';
import '../../../../../blocs/admin/settings/room/admin_room_event.dart';
import '../../../../../blocs/admin/settings/room/admin_room_state.dart';
import '../../../../../blocs/auth/auth_bloc.dart';
import '../../../../../blocs/auth/auth_state.dart';
import 'settings_sheet_helpers.dart';

class RoomConfigSheet extends StatefulWidget {
  const RoomConfigSheet({super.key});

  @override
  State<RoomConfigSheet> createState() => _RoomConfigSheetState();
}

class _RoomConfigSheetState extends State<RoomConfigSheet> {
  @override
  void initState() {
    super.initState();
    context.read<AdminRoomBloc>().add(AdminRoomFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        buildSheetHandle(),
        buildSheetHeader('Cấu hình phòng học', Icons.meeting_room_outlined),
        Expanded(
            child: BlocConsumer<AdminRoomBloc, AdminRoomState>(
              listener: (context, state) {
                if (state is AdminRoomActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
                } else if (state is AdminRoomActionFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
                }
              },
              builder: (context, state) {
                if (state is AdminRoomLoadInProgress || state is AdminRoomInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdminRoomLoadSuccess) {
                  final rooms = state.rooms;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (rooms.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text('Chưa có phòng học nào', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ),
                      ...rooms.map((r) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFEEEEEE)),
                            ),
                            child: Row(children: [
                              Icon(Icons.meeting_room_outlined, color: r.isActive == true ? const Color(0xFF1A237E) : Colors.grey, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                    Text('Phòng ${r.roomNumber}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 13, color: r.isActive == true ? Colors.black : Colors.grey)),
                                    Text('Sức chứa: ${r.capacity}  ·  ${r.isActive == true ? 'Hoạt động' : 'Bảo trì'}',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                                  ])),
                              Icon(Icons.edit_outlined, color: Colors.grey[400], size: 18),
                            ]),
                          )),
                      const SizedBox(height: 8),
                      buildSheetSubmitButton('+ Thêm phòng học', _showCreateDialog),
                    ],
                  );
                } else if (state is AdminRoomLoadFailure) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                }
                return const SizedBox();
              },
            )),
      ]),
    );
  }

  void _showCreateDialog() {
    final numCtrl = TextEditingController();
    final capCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm phòng học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: numCtrl, decoration: const InputDecoration(labelText: 'Số phòng (VD: A101)')),
            const SizedBox(height: 8),
            TextField(controller: capCtrl, decoration: const InputDecoration(labelText: 'Sức chứa'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthSuccess && authState.user.schoolId != null) {
                context.read<AdminRoomBloc>().add(AdminRoomCreated(
                      roomNumber: numCtrl.text.trim(),
                      capacity: int.tryParse(capCtrl.text.trim()) ?? 30,
                      isActive: true,
                      schoolBranchId: authState.user.schoolId!, // Simplification: using schoolId as branchId or fallback
                    ));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
            child: const Text('Tạo mới'),
          ),
        ],
      ),
    );
  }
}
