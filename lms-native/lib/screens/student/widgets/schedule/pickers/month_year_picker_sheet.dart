import 'package:flutter/material.dart';
import '../../../data/mock_schedule_data.dart';

class MonthYearPickerSheet extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final void Function(int year, int month) onSelected;

  const MonthYearPickerSheet({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.onSelected,
  });

  @override
  State<MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<MonthYearPickerSheet> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Year selector row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _year--),
              ),
              Text(
                '$_year',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _year++),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Month grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final m = i + 1;
              final sel = m == _month && _year == widget.initialYear;
              return GestureDetector(
                onTap: () {
                  widget.onSelected(_year, m);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: m == _month ? kPrimary : const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Th $m',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: m == _month
                          ? Colors.white
                          : const Color(0xFF424242),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
