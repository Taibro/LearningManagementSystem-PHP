import 'package:flutter/material.dart';
import 'package:learning_management_app/core/enum/AttendanceStatus.dart';
import 'package:learning_management_app/models/Attendance.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_management_app/repositories/student_repository.dart';
import 'widgets/attendance/attendance_card.dart';
import 'widgets/shared/custom_app_bar.dart';
import 'widgets/shared/mesh_background.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Attendance> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodayClasses();
  }

  Future<void> _fetchTodayClasses() async {
    try {
      final repo = context.read<StudentRepository>();
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final schedules = await repo.getWeeklySchedule(date: todayStr);
      
      final currentJavaDay = now.weekday; // 1 = Monday, 7 = Sunday
      final targetDay = currentJavaDay == 7 ? 8 : currentJavaDay + 1; 

      final todaySchedules = schedules.where((s) => s.dayOfWeek == targetDay).toList();

      final uniqueClasses = <String, dynamic>{};
      for (var s in todaySchedules) {
        uniqueClasses['${s.classCode}_${s.startPeriod}'] = s;
      }

      if (mounted) {
        setState(() {
          _items = uniqueClasses.values.map((s) {
            AttendanceStatus st = AttendanceStatus.chuaDiemDanh;
            if (s.attendanceStatus == 'PRESENT' || s.attendanceStatus == 'EXCUSED' || s.attendanceStatus == 'LATE') {
              st = AttendanceStatus.daDiemDanh;
            } else if (s.attendanceStatus == 'ABSENT') {
              st = AttendanceStatus.vang;
            }
            return Attendance(
              subjectName: s.courseName ?? '',
              tiet: '${s.startPeriod}→${s.endPeriod}',
              lop: s.classCode ?? '',
              phong: s.roomName ?? '',
              status: st,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Điểm danh'),
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                  : _items.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                          itemCount: _items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (_, i) => AttendanceCard(
                            item: _items[i],
                            onAttendanceSuccess: () {
                              setState(() {
                                _items[i].status = AttendanceStatus.daDiemDanh;
                              });
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'Không có môn học cần điểm danh',
        style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
      ),
    );
  }
}
