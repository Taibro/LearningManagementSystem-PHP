import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../../repositories/teacher_repository.dart';
import '../../../../models/lecturer/active_class_schedule.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/lecturer/teacher_attendance.dart';
import 'package:intl/intl.dart';

const Color _kPrimary = Color(0xFF6B4FA0);

class QrAttendanceTab extends StatefulWidget {
  const QrAttendanceTab({super.key});

  @override
  State<QrAttendanceTab> createState() => _QrAttendanceTabState();
}

class _QrAttendanceTabState extends State<QrAttendanceTab> {
  final ValueNotifier<int> _qrSeconds = ValueNotifier<int>(900); // 15 min
  Timer? _qrTimer;

  List<ActiveClassSchedule>? _activeClasses;
  ActiveClassSchedule? _selectedClass;
  ScheduleDetail? _selectedSchedule;
  int _selectedDuration = 15;
  String? _qrToken;
  bool _isLoading = true;
  String? _errorMsg;
  List<AttendanceDetail> _scannedStudents = [];
  Timer? _pollingTimer;

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

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _qrTimer?.cancel();
    _qrSeconds.dispose();
    super.dispose();
  }

  void _startQrTimer(int durationMinutes) {
    _qrTimer?.cancel();
    _qrSeconds.value = durationMinutes * 60;
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_qrSeconds.value > 0) {
        _qrSeconds.value--;
      } else {
        _qrTimer?.cancel();
        _pollingTimer?.cancel();
      }
    });
  }

  Future<void> _generateQrCode() async {
    if (_selectedClass == null || _selectedSchedule == null) return;
    try {
      final repo = context.read<TeacherRepository>();
      final response = await repo.generateQr({
        'classId': _selectedClass!.classId,
        'scheduleId': _selectedSchedule!.scheduleId,
        'validDuration': _selectedDuration,
      });
      setState(() {
        _qrToken = response['qrToken'];
      });
      _startQrTimer(_selectedDuration);
      _fetchScannedList();
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchScannedList());
      if (mounted) {
        _showQrBottomSheet(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _fetchScannedList() async {
    if (_selectedClass == null || _selectedSchedule == null) return;
    try {
      final repo = context.read<TeacherRepository>();
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final data = await repo.getAttendanceList(_selectedClass!.classId!, _selectedSchedule!.scheduleId!, dateStr);
      if (mounted) {
        setState(() {
          _scannedStudents = (data.students ?? [])
              .where((s) => s.attendanceStatus == 'PRESENT' || s.attendanceStatus == 'LATE')
              .toList();
        });
      }
    } catch (e) {
      // Ignore errors for polling
    }
  }

  String _formatQrTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CustomLoadingIndicator());
    }
    if (_errorMsg != null) {
      return Center(child: Text('Lỗi: $_errorMsg'));
    }
    if (_activeClasses == null || _activeClasses!.isEmpty) {
      return Center(child: Text('Không có lớp học nào.', style: GoogleFonts.inter(color: const Color(0xFF64748B))));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
      child: Column(
        children: [
          _buildQrForm().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          _buildQrScannedList().animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQrForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Tạo mã QR điểm danh',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDropdown<ActiveClassSchedule>(
            'Lớp học phần',
            _activeClasses!,
            _selectedClass,
            (c) => '${c.classCode} - ${c.courseName}',
            (v) => setState(() {
              _selectedClass = v;
              if (v != null && v.schedules != null && v.schedules!.isNotEmpty) {
                _selectedSchedule = v.schedules!.first;
              } else {
                _selectedSchedule = null;
              }
            }),
          ),
          const SizedBox(height: 16),
          if (_selectedClass != null && _selectedClass!.schedules != null && _selectedClass!.schedules!.isNotEmpty)
            _buildDropdown<ScheduleDetail>(
              'Buổi học',
              _selectedClass!.schedules!,
              _selectedSchedule,
              (s) => 'Thứ ${s.dayOfWeek}: Tiết ${s.startPeriod}-${s.endPeriod} (${s.roomName})',
              (v) => setState(() => _selectedSchedule = v),
            ),
          const SizedBox(height: 16),
          _buildDropdown<int>(
            'Thời gian hiệu lực',
            [5, 10, 15, 30],
            _selectedDuration,
            (d) => '$d phút',
            (v) => setState(() => _selectedDuration = v ?? 15),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _generateQrCode,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4FA0), Color(0xFF8B6BBF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Tạo mã QR',
                      style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
            ),
          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack, duration: 400.ms),
        ],
      ),
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

  void _showQrBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: _buildBottomSheetContent(),
        );
      },
    );
  }

  Widget _buildBottomSheetContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Mã QR Điểm danh',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
              boxShadow: [
                BoxShadow(
                  color: _kPrimary.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2_rounded,
                    size: 180, color: Color(0xFF6B4FA0)),
                const SizedBox(height: 16),
                Text(
                  _qrToken ?? 'HUIT-14DHTH04-${DateTime.now().millisecondsSinceEpoch % 99999}',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().scale(curve: Curves.easeOutBack, duration: 500.ms),
          const SizedBox(height: 32),
          ValueListenableBuilder<int>(
            valueListenable: _qrSeconds,
            builder: (context, seconds, child) {
              return Column(
                children: [
                  Text(
                    _formatQrTime(seconds),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF10B981),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Thời gian còn lại',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: seconds / 900,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      minHeight: 12,
                    ),
                  ),
                ],
              );
            },
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: Text('Tải về', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kPrimary,
                    side: const BorderSide(color: _kPrimary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text('Chia sẻ', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: _kPrimary.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                _fetchScannedList();
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text('Làm mới danh sách', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildQrScannedList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
                  'Sinh viên đã quét QR',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_scannedStudents.length} SV',
                    style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1.5, color: Color(0xFFF1F5F9)),
          ..._scannedStudents.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final isLate = s.attendanceStatus == 'LATE';
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isLate
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isLate
                              ? Icons.schedule_rounded
                              : Icons.check_circle_rounded,
                          color: isLate
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.studentName ?? 'Không rõ',
                                style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                            const SizedBox(height: 2),
                            Text(s.studentCode ?? 'N/A',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(DateFormat('HH:mm').format(DateTime.now()),
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLate
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isLate ? 'Vào trễ' : 'Đúng giờ',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isLate
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (i < _scannedStudents.length - 1)
                  const Divider(height: 1, indent: 80, color: Color(0xFFF1F5F9)),
              ],
            );
          }),
        ],
      ),
    );
  }
}
