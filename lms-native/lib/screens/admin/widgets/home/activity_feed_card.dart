import 'package:flutter/material.dart';
import '../../data/mock_admin_home_data.dart';
import 'home_helpers.dart';

class ActivityFeedCard extends StatelessWidget {
  const ActivityFeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return buildHomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            buildSectionTitle('Hoạt động gần đây', Icons.history_rounded),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('Xem tất cả', style: TextStyle(fontSize: 12, color: Color(0xFF1A237E))),
            ),
          ]),
          const SizedBox(height: 10),
          ...mockAdminActivities.asMap().entries.map((e) {
            final a = e.value;
            final col = a['color'] as Color;
            return Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 34, height: 34,
                  decoration: BoxDecoration(color: col.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(a['icon'] as IconData, color: col, size: 17)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a['msg'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF424242))),
                  const SizedBox(height: 2),
                  Text(a['time'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                ])),
              ]),
              if (e.key < mockAdminActivities.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 17, top: 4, bottom: 4),
                  child: Row(children: [
                    Container(width: 1, height: 16, color: const Color(0xFFE0E0E0)),
                  ]),
                ),
            ]);
          }),
        ],
      ),
    );
  }
}
