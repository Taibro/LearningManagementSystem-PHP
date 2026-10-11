import 'package:flutter/material.dart';
import '../../../data/mock_schedule_data.dart';
import '../../../utils/schedule_utils.dart';

class CalendarPickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime today;
  final void Function(DateTime) onDateSelected;

  const CalendarPickerSheet({
    super.key,
    required this.initialDate,
    required this.today,
    required this.onDateSelected,
  });

  @override
  State<CalendarPickerSheet> createState() => _CalendarPickerSheetState();
}

class _CalendarPickerSheetState extends State<CalendarPickerSheet> {
  late DateTime _viewMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selected = widget.initialDate;
  }

  void _prev() => setState(
    () => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1),
  );
  void _next() => setState(
    () => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1),
  );

  @override
  Widget build(BuildContext context) {
    final y = _viewMonth.year;
    final m = _viewMonth.month;
    final firstDay = DateTime(y, m, 1);
    final daysInMonth = DateTime(y, m + 1, 0).day;
    final startOffset = firstDay.weekday - 1; // Mon=0

    const wdLabels = ['Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'];

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────
            Row(
              children: [
                Text(
                  '${kMonthNames[m - 1]} $y',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kTextMain,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _prev,
                  child: const Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: kTextMain,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _next,
                  child: const Icon(
                    Icons.chevron_right,
                    size: 28,
                    color: kTextMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ── Day-of-week headers ──────────────────────────────
            Row(
              children: List.generate(7, (i) {
                final isWEnd = i >= 5;
                return Expanded(
                  child: Center(
                    child: Text(
                      wdLabels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isWEnd ? kRed : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            // ── Calendar Grid ─────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.05,
              ),
              itemCount: startOffset + daysInMonth,
              itemBuilder: (_, idx) {
                if (idx < startOffset) return const SizedBox();
                final day = idx - startOffset + 1;
                final date = DateTime(y, m, day);
                final isSel = sameDay(date, _selected);
                final isTod = sameDay(date, widget.today);
                final isWEnd = date.weekday >= 6;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selected = date);
                    widget.onDateSelected(date);
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSel ? kPrimary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isTod && !isSel
                            ? Border.all(color: kPrimary, width: 1.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSel
                              ? Colors.white
                              : isWEnd
                              ? kRed
                              : kTextMain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
