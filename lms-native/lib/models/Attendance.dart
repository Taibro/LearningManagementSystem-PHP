import 'package:learning_management_app/core/enum/AttendanceStatus.dart';

class Attendance {
  final String subjectName;
  final String tiet;
  final String lop;
  final String phong;
  AttendanceStatus status;

  Attendance({
    required this.subjectName,
    required this.tiet,
    required this.lop,
    required this.phong,
    this.status = AttendanceStatus.chuaDiemDanh,
  });
}
