import 'package:flutter/material.dart';
import 'package:learning_management_app/models/Schedule.dart';
import 'package:learning_management_app/models/student/student_schedule.dart';
import 'package:learning_management_app/repositories/student_repository.dart';
import 'package:learning_management_app/core/enum/ScheduleType.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/shared/mesh_background.dart';
import 'data/mock_schedule_data.dart' hide kData;
import 'utils/schedule_utils.dart';
import 'widgets/schedule/schedule_card.dart';
import 'widgets/schedule/empty_schedule_state.dart';
import 'widgets/schedule/schedule_legend.dart';
import 'widgets/schedule/pickers/calendar_picker_sheet.dart';
import 'widgets/schedule/pickers/year_picker_sheet.dart';
import 'widgets/schedule/pickers/week_picker_sheet.dart';
import 'widgets/schedule/pickers/month_year_picker_sheet.dart';
import '../../core/widgets/custom_loading_indicator.dart';

enum ViewMode { day, week, month }

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selected = DateTime.now();
  ViewMode _mode = ViewMode.day;
  Future<List<StudentSchedule>>? _scheduleFuture;
  final Map<String, List<Schedule>> _scheduleMap = {};

  @override
  void initState() {
    super.initState();
    _scheduleFuture = context.read<StudentRepository>().getProgressSchedule();
  }

  void _processData(List<StudentSchedule> apiSchedules) {
    _scheduleMap.clear();
    for (var s in apiSchedules) {
      if (s.startDate == null || s.endDate == null || s.dayOfWeek == null) continue;
      
      DateTime currentDate = s.startDate!;
      while (currentDate.isBefore(s.endDate!) || currentDate.isAtSameMomentAs(s.endDate!)) {
        int expectedWeekday = s.dayOfWeek! - 1; 
        
        if (currentDate.weekday == expectedWeekday) {
          final key = dateKey(currentDate);
          _scheduleMap.putIfAbsent(key, () => []);
          
          ScheduleType type = ScheduleType.lichHoc;
          if (s.sessionType == 'ONLINE') type = ScheduleType.lichTrucTuyen;
          if (s.sessionType == 'EXAM') type = ScheduleType.lichThi;
          
          _scheduleMap[key]!.add(Schedule(
            subjectName: s.courseName ?? '',
            tiet: '${s.startPeriod ?? ''} - ${s.endPeriod ?? ''}',
            phong: s.roomName ?? '',
            giangVien: s.teacherName ?? '',
            type: type,
          ));
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
  }

  bool _hasItems(DateTime d) => (_scheduleMap[dateKey(d)] ?? []).isNotEmpty;
  List<Schedule> _itemsFor(DateTime d) => _scheduleMap[dateKey(d)] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            _appBar(),
            _dateBar(),
            if (_mode == ViewMode.week) _weekStrip(),
            const ScheduleLegend(),
            Expanded(
              child: FutureBuilder<List<StudentSchedule>>(
                future: _scheduleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomLoadingIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  _processData(snapshot.data ?? []);
                  return _body();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    final canPop = Navigator.canPop(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0).withOpacity(0.5), width: 1.0)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: canPop ? 4 : 16,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        children: [
          if (canPop)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: canPop ? 0 : 22.0),
              child: Text(
                'Lịch học / Lịch thi',
                textAlign: TextAlign.center,
                style: TextStyle( // GoogleFonts.plusJakartaSans if imported
                  fontFamily: 'GoogleFonts.plusJakartaSans',
                  color: const Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const Icon(Icons.more_horiz_rounded, color: Color(0xFF64748B), size: 24),
        ],
      ),
    );
  }

  Widget _dateBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [_dateSelectorForMode(), const Spacer(), _viewModeTabs()],
      ),
    );
  }

  Widget _dateSelectorForMode() {
    switch (_mode) {
      case ViewMode.day:
        return _dropBtn(label: dayDateLong(_selected), onTap: _showDayPicker);

      case ViewMode.week:
        return Row(
          children: [
            _dropBtn(label: '${_selected.year}', onTap: _showYearPicker),
            const SizedBox(width: 10),
            _dropBtn(
              label: 'Tuần ${weekOfYear(_selected)}',
              onTap: _showWeekPicker,
            ),
          ],
        );

      case ViewMode.month:
        return _dropBtn(
          label: 'tháng ${_selected.month}, ${_selected.year}',
          onTap: _showMonthYearPicker,
        );
    }
  }

  Widget _dropBtn({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: kTextMain,
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 20, color: kTextMain),
        ],
      ),
    );
  }

  Widget _viewModeTabs() {
    const labels = ['Ngày', 'Tuần', 'Tháng'];
    const modes = ViewMode.values;
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final selected = _mode == modes[i];
          return GestureDetector(
            onTap: () => setState(() => _mode = modes[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? kPrimary : Colors.transparent,
                borderRadius: BorderRadius.horizontal(
                  left: i == 0 ? const Radius.circular(7) : Radius.zero,
                  right: i == 2 ? const Radius.circular(7) : Radius.zero,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF616161),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Week Strip ────────────────────────────────────────────────────

  Widget _weekStrip() {
    final monday = weekStart(_selected);
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Row(
        children: List.generate(7, (i) {
          final day = monday.add(Duration(days: i));
          final isSel = sameDay(day, _selected);
          final isWEnd = day.weekday >= 6;
          final hasDot = _hasItems(day);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selected = day),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Weekday label
                  Text(
                    wdShort(day.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSel
                          ? const Color(0xFF4F46E5)
                          : isWEnd
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: isSel ? const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) : null,
                      color: isSel ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSel ? [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSel
                            ? Colors.white
                            : isWEnd
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Event dot
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: hasDot ? const Color(0xFFF59E0B) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Body dispatcher ───────────────────────────────────────────────

  Widget _body() {
    switch (_mode) {
      case ViewMode.day:
        return _dayView();
      case ViewMode.week:
        return _weekView();
      case ViewMode.month:
        return _monthView();
    }
  }

  // ── Day View ──────────────────────────────────────────────────────

  Widget _dayView() {
    final items = _itemsFor(_selected);
    if (items.isEmpty) return EmptyScheduleState(date: _selected);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 120),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => ScheduleCard(item: items[i]),
    );
  }

  // ── Week View ─────────────────────────────────────────────────────

  Widget _weekView() {
    final monday = weekStart(_selected);
    final groups = <(DateTime, List<Schedule>)>[];
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final it = _itemsFor(d);
      if (it.isNotEmpty) groups.add((d, it));
    }
    if (groups.isEmpty) return EmptyScheduleState(date: _selected);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 120),
      itemCount: groups.length,
      itemBuilder: (_, gi) {
        final (date, items) = groups[gi];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gi > 0) const SizedBox(height: 14),
            _groupHeader(date),
            const SizedBox(height: 8),
            ...items.map(
              (it) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ScheduleCard(item: it),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _monthView() {
    final y = _selected.year;
    final m = _selected.month;
    final daysInMonth = DateTime(y, m + 1, 0).day;

    final groups = <(DateTime, List<Schedule>)>[];
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(y, m, d);
      final it = _itemsFor(date);
      if (it.isNotEmpty) groups.add((date, it));
    }

    return CustomScrollView(
      slivers: [
        // ── Calendar card ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: _calendarGrid(y, m),
          ),
        ),

        if (groups.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: EmptyScheduleState(date: _selected),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((_, gi) {
              final (date, items) = groups[gi];
              return Padding(
                padding: EdgeInsets.fromLTRB(14, gi == 0 ? 14 : 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _groupHeader(date),
                    const SizedBox(height: 8),
                    ...items.map(
                      (it) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ScheduleCard(item: it),
                      ),
                    ),
                  ],
                ),
              );
            }, childCount: groups.length),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  /// Calendar grid widget
  Widget _calendarGrid(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startOffset = firstDay.weekday - 1;

    const wdLabels = ['Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'];

    return Column(
      children: [
        // Day-of-week headers
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
        const SizedBox(height: 6),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: startOffset + daysInMonth,
          itemBuilder: (_, idx) {
            if (idx < startOffset) return const SizedBox();
            final day = idx - startOffset + 1;
            final date = DateTime(year, month, day);
            final isSel = sameDay(date, _selected);
            final isTod = sameDay(date, kToday);
            final isWEnd = date.weekday >= 6;
            final hasDot = _hasItems(date);

            return GestureDetector(
              onTap: () => setState(() => _selected = date),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSel
                            ? Colors.white
                            : isWEnd
                            ? kRed
                            : kTextMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: hasDot ? kOrange : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _groupHeader(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        dayDateShort(date),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  //--------------------------------------------------------------------
  void _showDayPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
      ),
      builder: (_) => CalendarPickerSheet(
        initialDate: _selected,
        today: kToday,
        onDateSelected: (d) => setState(() => _selected = d),
      ),
    );
  }

  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
      ),
      builder: (_) => YearPickerSheet(
        initialYear: _selected.year,
        onYearSelected: (y) => setState(() {
          final day = _selected.day.clamp(
            1,
            DateTime(y, _selected.month + 1, 0).day,
          );
          _selected = DateTime(y, _selected.month, day);
        }),
      ),
    );
  }

  void _showWeekPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => WeekPickerSheet(
        initialDate: _selected,
        onWeekSelected: (monday) => setState(() => _selected = monday),
      ),
    );
  }

  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MonthYearPickerSheet(
        initialYear: _selected.year,
        initialMonth: _selected.month,
        onSelected: (y, m) {
          final day = _selected.day.clamp(1, DateTime(y, m + 1, 0).day);
          setState(() => _selected = DateTime(y, m, day));
        },
      ),
    );
  }
}
