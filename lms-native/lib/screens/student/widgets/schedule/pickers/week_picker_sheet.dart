import 'package:flutter/material.dart';
import '../../../data/mock_schedule_data.dart';
import '../../../utils/schedule_utils.dart';

class WeekPickerSheet extends StatelessWidget {
  final DateTime initialDate;
  final void Function(DateTime monday) onWeekSelected;

  const WeekPickerSheet({
    super.key,
    required this.initialDate,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    final year = initialDate.year;

    DateTime firstMon = DateTime(year, 1, 1);
    while (firstMon.weekday != DateTime.monday) {
      firstMon = firstMon.add(const Duration(days: 1));
    }

    final weeks = <(int, DateTime, DateTime)>[];
    for (int w = 0; w < 53; w++) {
      final monday = firstMon.add(Duration(days: w * 7));
      if (monday.year > year) break;
      final sunday = monday.add(const Duration(days: 6));
      weeks.add((w + 2, monday, sunday));
    }

    final currentWeek = weekOfYear(initialDate);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.8,
      minChildSize: 0.3,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chọn tuần',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                itemCount: weeks.length,
                itemBuilder: (_, i) {
                  final (wNum, mon, sun) = weeks[i];
                  final selected = wNum == currentWeek;
                  return ListTile(
                    title: Text(
                      'Tuần $wNum  (${ddMM(mon)} - ${ddMM(sun)})',
                      style: TextStyle(
                        fontSize: 13,
                        color: selected ? kPrimary : kTextMain,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check, color: kPrimary)
                        : null,
                    onTap: () {
                      onWeekSelected(mon);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
