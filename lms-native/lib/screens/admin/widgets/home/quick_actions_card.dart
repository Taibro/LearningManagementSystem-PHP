import 'package:flutter/material.dart';
import 'home_helpers.dart';

class QuickActionsCard extends StatelessWidget {
  final Function(String) onAction;
  const QuickActionsCard({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.person_add_outlined,       'label': 'Thêm\nsinh viên',  'color': const Color(0xFF1A237E)},
      {'icon': Icons.person_add_alt_1_outlined, 'label': 'Thêm\ngiảng viên', 'color': const Color(0xFF2E7D32)},
      {'icon': Icons.add_box_outlined,          'label': 'Thêm\nlớp học',    'color': const Color(0xFFE65100)},
      {'icon': Icons.campaign_outlined,         'label': 'Thông\nbáo',       'color': const Color(0xFFE85D75)},
      {'icon': Icons.calendar_month_outlined,   'label': 'Cập nhật\nlịch',   'color': const Color(0xFF00695C)},
      {'icon': Icons.backup_outlined,           'label': 'Sao lưu\nDL',      'color': const Color(0xFF5C6BC0)},
    ];

    return buildHomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle('Thao tác nhanh', Icons.flash_on_rounded),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.3,
            ),
            itemCount: actions.length,
            itemBuilder: (_, i) {
              final a = actions[i];
              final col = a['color'] as Color;
              return GestureDetector(
                onTap: () => onAction(a['label'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: col.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: col.withOpacity(0.2)),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(a['icon'] as IconData, color: col, size: 26),
                    const SizedBox(height: 6),
                    Text(a['label'] as String, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: col, fontWeight: FontWeight.w600, height: 1.3)),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
