import 'package:flutter/material.dart';
import 'settings_sheet_helpers.dart';

class ActivityLogSheet extends StatelessWidget {
  const ActivityLogSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF1A237E);
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        buildSheetHandle(),
        buildSheetHeader('Nhật ký hoạt động', Icons.history_rounded),
        Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
          ...[
            {
              'msg': 'Admin duyệt đề xuất dạy bù – GV Nguyễn Văn A',
              'time': '28/04 – 09:12',
              'icon': Icons.check_circle_outline,
              'color': const Color(0xFF4CAF50)
            },
            {
              'msg': 'Admin cập nhật phòng học A107',
              'time': '27/04 – 15:44',
              'icon': Icons.edit_outlined,
              'color': kPrimary
            },
            {
              'msg': 'Xuất báo cáo điểm danh HK2',
              'time': '25/04 – 10:20',
              'icon': Icons.download_outlined,
              'color': const Color(0xFFE65100)
            },
            {
              'msg': 'Khoá tài khoản SV 12DHBM05001',
              'time': '22/04 – 11:05',
              'icon': Icons.block,
              'color': const Color(0xFFC62828)
            },
            {
              'msg': 'Tạo học kỳ HK2 2025-2026',
              'time': '28/01 – 08:00',
              'icon': Icons.add_box_outlined,
              'color': const Color(0xFF2E7D32)
            },
          ].map((log) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEEEEE))),
                child: Row(children: [
                  Icon(log['icon'] as IconData,
                      color: log['color'] as Color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(log['msg'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF424242)))),
                  Text(log['time'] as String,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF9E9E9E))),
                ]),
              )),
        ])),
      ]),
    );
  }
}
