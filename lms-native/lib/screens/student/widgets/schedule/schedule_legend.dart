import 'package:flutter/material.dart';
import '../../data/mock_schedule_data.dart';

class ScheduleLegend extends StatelessWidget {
  const ScheduleLegend({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (kGreen, 'Lịch học'),
      (kYellow, 'Lịch thi'),
      (kPrimary, 'Lịch trực tuyến'),
      (kRed, 'Tạm ngưng'),
    ];
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      alignment: Alignment.center,
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: items.map((e) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(color: e.$1, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                e.$2,
                style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
