import 'package:flutter/material.dart';
import '../../data/mock_admin_schedule_data.dart';

class RoomsTab extends StatelessWidget {
  const RoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF1A237E);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(children: [
        // Summary chips
        Row(children: [
          _roomSummaryChip('Trống', mockRooms.where((r) => r['status'] == 'available').length.toString(), const Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          _roomSummaryChip('Đang dùng', mockRooms.where((r) => r['status'] == 'occupied').length.toString(), kPrimary),
          const SizedBox(width: 8),
          _roomSummaryChip('Bảo trì', mockRooms.where((r) => r['status'] == 'maintenance').length.toString(), const Color(0xFFE85D75)),
        ]),
        const SizedBox(height: 14),
        ...mockRooms.map((r) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _buildRoomCard(r))),
      ]),
    );
  }

  Widget _roomSummaryChip(String label, String count, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: col)),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ]),
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> r) {
    const kPrimary = Color(0xFF1A237E);
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (r['status']) {
      case 'occupied':    statusColor = kPrimary;                  statusLabel = 'Đang dùng'; statusIcon = Icons.lock_outline_rounded; break;
      case 'maintenance': statusColor = const Color(0xFFE85D75);    statusLabel = 'Bảo trì';   statusIcon = Icons.build_outlined; break;
      default:            statusColor = const Color(0xFF4CAF50);    statusLabel = 'Trống';      statusIcon = Icons.check_circle_outline;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.meeting_room_outlined, color: statusColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 3),
          Text('Sức chứa: ${r['capacity']}  ·  ${r['facility']}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(statusIcon, size: 12, color: statusColor),
            const SizedBox(width: 4),
            Text(statusLabel, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}
