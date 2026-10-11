import 'package:flutter/material.dart';
import 'schedule_sheet_helpers.dart';

class ChangeRoomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final Map<String, dynamic> currentClass;
  const ChangeRoomSheet({super.key, required this.rooms, required this.currentClass});

  @override
  Widget build(BuildContext context) {
    final available = rooms.where((r) => r['status'] == 'available').toList();
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        buildSheetHandle(),
        buildSheetHeader('Đổi phòng học', Icons.meeting_room_outlined),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
                'Phòng hiện tại: ${currentClass['room']}  ·  ${currentClass['session']}',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF9E9E9E)))),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
        Expanded(
            child: ListView(padding: const EdgeInsets.all(14), children: [
          const Text('Phòng đang trống:',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242))),
          const SizedBox(height: 10),
          ...available.map((r) => GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.meeting_room_outlined,
                        color: Color(0xFF4CAF50), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(r['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(
                              'Sức chứa: ${r['capacity']}  ·  ${r['facility']}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E))),
                        ])),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: Color(0xFF4CAF50)),
                  ]),
                ),
              )),
        ])),
      ]),
    );
  }
}
