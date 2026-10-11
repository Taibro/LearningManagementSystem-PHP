import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/teacher_repository.dart';
import '../../../../models/lecturer/teacher_schedule.dart';
import 'package:intl/intl.dart';

class WeeklyTab extends StatefulWidget {
  const WeeklyTab({super.key});

  @override
  State<WeeklyTab> createState() => _WeeklyTabState();
}

class _WeeklyTabState extends State<WeeklyTab> {
  int _weekOffset = 0;
  List<TeacherSchedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<TeacherRepository>();
      final targetDate = DateTime.now().add(Duration(days: _weekOffset * 7));
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
      
      final schedules = await repo.getWeeklySchedule(date: dateStr);
      
      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _changeWeek(int offset) {
    setState(() {
      _weekOffset += offset;
    });
    _fetchSchedule();
  }

  void _resetWeek() {
    setState(() {
      _weekOffset = 0;
    });
    _fetchSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekNavigator(),
        _buildLegend(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B4FA0)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  child: Column(
                    children: List.generate(7, (dayIndex) {
                      final targetDayOfWeek = dayIndex + 2; // 0 (Mon) -> 2, 6 (Sun) -> 8
                      final classes = _schedules.where((s) => s.dayOfWeek == targetDayOfWeek).toList();
                      return _buildDayRow(dayIndex, classes)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: (50 * dayIndex).ms)
                          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
                    }),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildWeekNavigator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _changeWeek(-1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chevron_left_rounded, color: Color(0xFF6B4FA0), size: 24),
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final targetDate = DateTime.now().add(Duration(days: _weekOffset * 7));
                final weekStart = targetDate.subtract(Duration(days: targetDate.weekday - 1));
                final weekEnd = targetDate.add(Duration(days: 7 - targetDate.weekday));
                final df = DateFormat('dd/MM/yyyy');
                return Text(
                  'Tuần ${DateFormat('dd/MM').format(weekStart)} – ${df.format(weekEnd)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                );
              },
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _changeWeek(1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B4FA0), size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: const Color(0xFF6B4FA0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _resetWeek,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  'Hôm nay',
                  style: TextStyle(
                    color: Color(0xFF6B4FA0),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      {'color': const Color(0xFF10B981), 'label': 'Lý thuyết'},
      {'color': const Color(0xFF3B82F6), 'label': 'Thực hành'},
      {'color': const Color(0xFFF59E0B), 'label': 'Trực tuyến'},
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      child: Row(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayRow(int dayIndex, List<TeacherSchedule> classes) {
    final now = DateTime.now();
    final targetDate = DateTime.now().add(Duration(days: _weekOffset * 7));
    final weekStart = targetDate.subtract(Duration(days: targetDate.weekday - 1));
    final dayDate = weekStart.add(Duration(days: dayIndex));
    final isToday = now.year == dayDate.year && now.month == dayDate.month && now.day == dayDate.day;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToday ? const Color(0xFF6B4FA0) : const Color(0xFFF1F5F9),
          width: isToday ? 2 : 1.5,
        ),
        boxShadow: [
          if (isToday)
            BoxShadow(
              color: const Color(0xFF6B4FA0).withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFF6B4FA0).withOpacity(0.08)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Text(
                  ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][dayIndex],
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isToday ? const Color(0xFF6B4FA0) : const Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) {
                    final targetDate = DateTime.now().add(Duration(days: _weekOffset * 7));
                    final weekStart = targetDate.subtract(Duration(days: targetDate.weekday - 1));
                    final dayDate = weekStart.add(Duration(days: dayIndex));
                    return Text(
                      DateFormat('dd/MM').format(dayDate),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isToday ? const Color(0xFF6B4FA0).withOpacity(0.8) : const Color(0xFF64748B),
                      ),
                    );
                  }
                ),
                if (isToday) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4FA0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Hôm nay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '${classes.length} buổi',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (classes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Không có lịch dạy',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: classes
                    .map((cls) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildScheduleChip(cls),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleChip(TeacherSchedule cls) {
    Color color;
    Color bgColor;
    // Map sessionType to color
    // "Lý thuyết" -> green, "Thực hành" -> blue, "Trực tuyến" -> yellow
    final sessionType = (cls.sessionType ?? '').toLowerCase();
    if (sessionType.contains('thực hành')) {
      color = const Color(0xFF3B82F6);
      bgColor = const Color(0xFF3B82F6).withOpacity(0.08);
    } else if (sessionType.contains('trực tuyến')) {
      color = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFF59E0B).withOpacity(0.08);
    } else {
      color = const Color(0xFF10B981);
      bgColor = const Color(0xFF10B981).withOpacity(0.08);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cls.courseName ?? 'Môn học',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: color.withOpacity(0.9),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cls.classCode ?? 'Mã lớp',
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: color),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cls.roomName ?? 'Phòng học',
                          style: TextStyle(
                            fontSize: 12,
                            color: color.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tiết ${cls.startPeriod}-${cls.endPeriod}',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
