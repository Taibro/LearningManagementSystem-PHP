import 'package:flutter/material.dart';
import 'package:learning_management_app/core/enum/ScheduleType.dart';
import '../data/mock_schedule_data.dart';

String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String wdShort(int wd) => wd == 7 ? 'CN' : 'Th ${wd + 1}';

String ddMM(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String ddMMYYYY(DateTime d) => '${ddMM(d)}/${d.year}';

String dayDateLong(DateTime d) => '${wdShort(d.weekday)}, ${ddMMYYYY(d)}';

String dayDateShort(DateTime d) => '${wdShort(d.weekday)}, ${ddMM(d)}';

int weekOfYear(DateTime d) {
  DateTime firstMon = DateTime(d.year, 1, 1);
  while (firstMon.weekday != DateTime.monday) {
    firstMon = firstMon.add(const Duration(days: 1));
  }
  if (d.isBefore(firstMon)) return 1;
  return d.difference(firstMon).inDays ~/ 7 + 2;
}

DateTime weekStart(DateTime d) =>
    DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

Color typeColor(ScheduleType t) {
  switch (t) {
    case ScheduleType.lichHoc:
      return kGreen;
    case ScheduleType.lichThi:
      return kYellow;
    case ScheduleType.lichTrucTuyen:
      return kPrimary;
    case ScheduleType.tamNgung:
      return kRed;
  }
}
