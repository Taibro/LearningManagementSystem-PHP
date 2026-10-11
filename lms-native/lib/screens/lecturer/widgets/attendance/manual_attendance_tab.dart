import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/lecturer/attendance/teacher_attendance_bloc.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../blocs/lecturer/attendance/teacher_attendance_event.dart';
import '../../../../blocs/lecturer/attendance/teacher_attendance_state.dart';
import '../../../../models/lecturer/teacher_attendance.dart';
import '../../../../repositories/teacher_repository.dart';
import '../../../../models/lecturer/active_class_schedule.dart';
import 'package:intl/intl.dart';

const Color _kPrimary = Color(0xFF6B4FA0);

class ManualAttendanceTab extends StatefulWidget {
  const ManualAttendanceTab({super.key});

  @override
  State<ManualAttendanceTab> createState() => _ManualAttendanceTabState();
}

class _ManualAttendanceTabState extends State<ManualAttendanceTab> {
  String _searchQuery = '';
  final TextEditingController _commentController =
      TextEditingController(text: 'Lớp học nghiêm túc, đúng giờ.');

  List<ActiveClassSchedule>? _activeClasses;
  ActiveClassSchedule? _selectedClass;
  ScheduleDetail? _selectedSchedule;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchActiveClasses();
  }

  Future<void> _fetchActiveClasses() async {
    try {
      final repo = context.read<TeacherRepository>();
      final classes = await repo.getActiveClasses();
      if (mounted) {
        setState(() {
          _activeClasses = classes;
          _isLoading = false;
          if (classes.isNotEmpty) {
            _selectedClass = classes.first;
            if (_selectedClass!.schedules != null && _selectedClass!.schedules!.isNotEmpty) {
              _selectedSchedule = _selectedClass!.schedules!.first;
            }
          }
        });
        _fetchAttendance();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = e.toString();
        });
      }
    }
  }

  void _fetchAttendance() {
    if (_selectedClass == null || _selectedSchedule == null) return;
    context.read<TeacherAttendanceBloc>().add(
          TeacherAttendanceFetchRequested(
            classId: _selectedClass!.classId!,
            scheduleId: _selectedSchedule!.scheduleId!,
            date: _selectedDate,
          ),
        );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CustomLoadingIndicator());
    }
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMsg',
              style: GoogleFonts.inter(color: const Color(0xFFEF4444)),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.1),
      );
    }
    if (_activeClasses == null || _activeClasses!.isEmpty) {
      return Center(
        child: Text('Không có lớp học nào.', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
      );
    }

    return BlocBuilder<TeacherAttendanceBloc, TeacherAttendanceState>(
      builder: (context, state) {
        if (state is TeacherAttendanceLoading) {
          return Center(child: CustomLoadingIndicator());
        } else if (state is TeacherAttendanceLoadFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${state.message}',
                  style: GoogleFonts.inter(color: const Color(0xFFEF4444)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _fetchAttendance, child: const Text('Thử lại')),
              ],
            ).animate().fadeIn().slideY(begin: 0.1),
          );
        } else if (state is TeacherAttendanceLoadSuccess) {
          return _buildContent(state.attendanceList);
        }
        return _buildContent(TeacherAttendanceList(students: [])); // show empty state with filters
      },
    );
  }

  Widget _buildContent(TeacherAttendanceList data) {
    final studentsList = data.students ?? [];

    final present = studentsList.where((s) => s.attendanceStatus == 'PRESENT').length;
    final excused = studentsList.where((s) => s.attendanceStatus == 'LATE').length; // using LATE for now
    final absent = studentsList.where((s) => s.attendanceStatus == 'ABSENT').length;

    final filtered = _searchQuery.isEmpty
        ? studentsList
        : studentsList
            .where((s) =>
                (s.studentName ?? '')
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                (s.studentCode ?? '')
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      child: Column(
        children: [
          // Filter card
          _buildFilterCard().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          // Stats
          Row(
            children: [
              _buildStatChip('Sĩ số', '${studentsList.length}', const Color(0xFF3B82F6), 0),
              const SizedBox(width: 12),
              _buildStatChip('Có mặt', '$present', const Color(0xFF10B981), 1),
              const SizedBox(width: 12),
              _buildStatChip('Vắng (P)', '$excused', const Color(0xFFF59E0B), 2),
              const SizedBox(width: 12),
              _buildStatChip('Vắng (KP)', '$absent', const Color(0xFFEF4444), 3),
            ],
          ),
          const SizedBox(height: 24),
          // Comment
          _buildCommentCard(data).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          // Student list
          _buildStudentList(filtered).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildDropdown<ActiveClassSchedule>(
                  'Lớp học phần',
                  _activeClasses!,
                  _selectedClass,
                  (c) => '${c.classCode} - ${c.courseName}',
                  (v) {
                    setState(() {
                      _selectedClass = v;
                      if (v != null && v.schedules != null && v.schedules!.isNotEmpty) {
                        _selectedSchedule = v.schedules!.first;
                      } else {
                        _selectedSchedule = null;
                      }
                    });
                    _fetchAttendance();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: _buildDatePicker(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedClass != null && _selectedClass!.schedules != null && _selectedClass!.schedules!.isNotEmpty)
            _buildDropdown<ScheduleDetail>(
              'Buổi học (Lịch cố định)',
              _selectedClass!.schedules!,
              _selectedSchedule,
              (s) => 'Thứ ${s.dayOfWeek}: Tiết ${s.startPeriod}-${s.endPeriod} (${s.roomName})',
              (v) {
                setState(() {
                  _selectedSchedule = v;
                });
                _fetchAttendance();
              },
            ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sinh viên...',
              hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6B4FA0), width: 1.5),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B), fontWeight: FontWeight.w500),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày học',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.parse(_selectedDate),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF6B4FA0),
                      onPrimary: Colors.white,
                      onSurface: Color(0xFF1E293B),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _selectedDate = DateFormat('yyyy-MM-dd').format(date);
              });
              _fetchAttendance();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.parse(_selectedDate)),
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(String label, List<T> items, T? value,
      String Function(T) labelBuilder, ValueChanged<T?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(labelBuilder(e),
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color, int index) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: color.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 400.ms, delay: (50 * index).ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildCommentCard(TeacherAttendanceList data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nhận xét lớp',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 2,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6B4FA0), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionBtn('Lưu điểm danh', const Color(0xFF6B4FA0), Icons.save_rounded, () async {
                  if (_selectedClass == null || _selectedSchedule == null) return;
                  final bloc = context.read<TeacherAttendanceBloc>();
                  int successCount = 0;
                  for (final s in (data.students ?? [])) {
                    bloc.add(TeacherAttendanceSaveRequested(
                      classId: _selectedClass!.classId!,
                      scheduleId: _selectedSchedule!.scheduleId!,
                      sessionDate: _selectedDate,
                      studentCode: s.studentCode ?? '',
                      status: s.attendanceStatus ?? 'PRESENT',
                      notes: _commentController.text,
                    ));
                    successCount++;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã lưu điểm danh cho $successCount sinh viên', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFF6B4FA0),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                _buildActionBtn('Xuất Excel', const Color(0xFF10B981), Icons.table_chart_rounded, null),
                const SizedBox(width: 12),
                _buildActionBtn('Đồng bộ', const Color(0xFF3B82F6), Icons.sync_rounded, null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList(List<AttendanceDetail> list) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách sinh viên',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4FA0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${list.length} SV',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B4FA0),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1.5, color: Color(0xFFF1F5F9)),
          ...list.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Column(
              children: [
                _buildStudentRow(i, s),
                if (i < list.length - 1)
                  const Divider(height: 1, thickness: 1, indent: 20, color: Color(0xFFF1F5F9)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStudentRow(int index, AttendanceDetail s) {
    final labels = ['Có mặt', 'Vắng phép', 'Vắng'];
    final statuses = ['PRESENT', 'LATE', 'ABSENT']; // Using LATE as excused absence for now
    
    int getStatusIndex(String status) {
      if (status == 'LATE') return 1;
      if (status == 'ABSENT') return 2;
      return 0; // PRESENT
    }
    
    final sIndex = getStatusIndex(s.attendanceStatus ?? 'PRESENT');

    final colors = [
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.studentName ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${s.studentCode ?? ''}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Status toggle
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  final nextIndex = (sIndex + 1) % 3;
                  s.attendanceStatus = statuses[nextIndex];
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors[sIndex].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors[sIndex].withOpacity(0.2), width: 1.5),
                ),
                child: Text(
                  labels[sIndex],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: colors[sIndex],
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
}
