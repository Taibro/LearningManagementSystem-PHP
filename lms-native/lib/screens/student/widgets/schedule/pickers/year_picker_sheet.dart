import 'package:flutter/material.dart';
import '../../../data/mock_schedule_data.dart';

class YearPickerSheet extends StatelessWidget {
  final int initialYear;
  final void Function(int) onYearSelected;

  const YearPickerSheet({
    super.key,
    required this.initialYear,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    const years = [2024, 2025, 2026, 2027, 2028];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn năm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...years.map((y) {
            final selected = y == initialYear;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '$y',
                style: TextStyle(
                  color: selected ? kPrimary : kTextMain,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: selected
                  ? const Icon(Icons.check, color: kPrimary)
                  : null,
              onTap: () {
                onYearSelected(y);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}
