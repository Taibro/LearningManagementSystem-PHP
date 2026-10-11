import 'package:flutter/material.dart';
import 'settings_helpers.dart';
import 'bottom_sheets/broadcast_sheet.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key});

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF1A237E);
    final announcements = [
      {'title': 'Lịch thi HK2 2025-2026 đã có', 'target': 'Tất cả', 'date': '10/05/2026', 'type': 'info'},
      {'title': 'Nhắc nhở nộp bảng điểm trước 20/05', 'target': 'Giảng viên', 'date': '08/05/2026', 'type': 'warning'},
      {'title': 'Hệ thống bảo trì 23:00 – 01:00', 'target': 'Tất cả', 'date': '05/05/2026', 'type': 'danger'},
    ];

    return buildSettingsCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          buildSectionTitle('Thông báo đã gửi', Icons.campaign_outlined),
          GestureDetector(
            onTap: () => _showBroadcastSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: kPrimary, borderRadius: BorderRadius.circular(20)),
              child: const Row(children: [
                Icon(Icons.add, color: Colors.white, size: 14),
                SizedBox(width: 3),
                Text('Tạo mới',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        ...announcements.map((a) {
          Color col;
          IconData icon;
          switch (a['type']) {
            case 'warning':
              col = const Color(0xFFE65100);
              icon = Icons.warning_amber_outlined;
              break;
            case 'danger':
              col = const Color(0xFFC62828);
              icon = Icons.error_outline;
              break;
            default:
              col = kPrimary;
              icon = Icons.info_outline;
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: col.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: col.withOpacity(0.2)),
            ),
            child: Row(children: [
              Icon(icon, color: col, size: 20),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(a['title']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Gửi tới: ${a['target']}  ·  ${a['date']}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9E9E9E))),
                  ])),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
            ]),
          );
        }),
      ]),
    );
  }

  void _showBroadcastSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BroadcastSheet(),
    );
  }
}
