import 'package:flutter/material.dart';
import 'shared_sheet_helpers.dart';

class StatisticsSheet extends StatelessWidget {
  const StatisticsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Tổng tiết đã dạy', 'value': '87 tiết', 'color': const Color(0xFF6B4FA0)},
      {'label': 'Tiết lý thuyết', 'value': '45 tiết', 'color': const Color(0xFF4CAF50)},
      {'label': 'Tiết thực hành', 'value': '30 tiết', 'color': const Color(0xFF5C6BC0)},
      {'label': 'Tiết trực tuyến', 'value': '12 tiết', 'color': const Color(0xFFE65100)},
      {'label': 'Số buổi coi thi', 'value': '3 buổi', 'color': const Color(0xFFE85D75)},
      {'label': 'Tiết vượt kế hoạch', 'value': '+12 tiết', 'color': const Color(0xFF2E7D32)},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          buildSheetHandle(),
          buildSheetHeader('Thống kê thực giảng', 'HK2 - 2025/2026',
              const Color(0xFF4CAF50)),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: stats.length,
              itemBuilder: (_, i) {
                final s = stats[i];
                final color = s['color'] as Color;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s['value'] as String,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      Text(s['label'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
