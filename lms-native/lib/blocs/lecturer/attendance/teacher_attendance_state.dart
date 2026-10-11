import 'package:equatable/equatable.dart';
import '../../../models/lecturer/teacher_attendance.dart';

abstract class TeacherAttendanceState extends Equatable {
  const TeacherAttendanceState();

  @override
  List<Object?> get props => [];
}

class TeacherAttendanceInitial extends TeacherAttendanceState {}

class TeacherAttendanceLoading extends TeacherAttendanceState {}

class TeacherAttendanceLoadSuccess extends TeacherAttendanceState {
  final TeacherAttendanceList attendanceList;

  const TeacherAttendanceLoadSuccess(this.attendanceList);

  @override
  List<Object?> get props => [attendanceList];
}

class TeacherAttendanceLoadFailure extends TeacherAttendanceState {
  final String message;

  const TeacherAttendanceLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TeacherAttendanceSaveSuccess extends TeacherAttendanceState {}

class TeacherAttendanceSaveFailure extends TeacherAttendanceState {
  final String message;

  const TeacherAttendanceSaveFailure(this.message);

  @override
  List<Object?> get props => [message];
}
