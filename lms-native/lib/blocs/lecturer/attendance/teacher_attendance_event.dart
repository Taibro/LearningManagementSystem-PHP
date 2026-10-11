import 'package:equatable/equatable.dart';

abstract class TeacherAttendanceEvent extends Equatable {
  const TeacherAttendanceEvent();

  @override
  List<Object?> get props => [];
}

class TeacherAttendanceFetchRequested extends TeacherAttendanceEvent {
  final int classId;
  final int scheduleId;
  final String date; // YYYY-MM-DD

  const TeacherAttendanceFetchRequested({
    required this.classId,
    required this.scheduleId,
    required this.date,
  });

  @override
  List<Object?> get props => [classId, scheduleId, date];
}

class TeacherAttendanceSaveRequested extends TeacherAttendanceEvent {
  final int classId;
  final int scheduleId;
  final String sessionDate;
  final String studentCode;
  final String status;
  final String? notes;

  const TeacherAttendanceSaveRequested({
    required this.classId,
    required this.scheduleId,
    required this.sessionDate,
    required this.studentCode,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [classId, scheduleId, sessionDate, studentCode, status, notes];
}
