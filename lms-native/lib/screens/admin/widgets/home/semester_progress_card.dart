import 'package:flutter/material.dart';
import 'home_helpers.dart';

class SemesterProgressCard extends StatelessWidget {
  const SemesterProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Tiến độ giảng dạy toàn trường', 'pct': 0.72, 'color': const Color(0xFF1A237E)},
      {'label': 'Tỉ lệ điểm danh trung bình',     'pct': 0.89, 'color': const Color(0xFF4CAF50)},
      {'label': 'Tỉ lệ nộp bảng điểm đúng hạn',  'pct': 0.61, 'color': const Color(0xFFE65100)},
    ];

    return buildHomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle('Tiến độ học kỳ 2 – 2025/2026', Icons.trending_up_rounded),
          const SizedBox(height: 14),
          ...items.map((item) {
            final col = item['color'] as Color;
            final pct = item['pct'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(item['label'] as String, style: const TextStyle(fontSize: 13, color: Color(0xFF424242))),
                    Text('${(pct * 100).toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: col)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: const Color(0xFFE8E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(col),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
