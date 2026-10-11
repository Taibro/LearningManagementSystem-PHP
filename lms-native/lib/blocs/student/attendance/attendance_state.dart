import 'package:equatable/equatable.dart';
import '../../../models/student/student_attendance.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoadSuccess extends AttendanceState {
  final List<StudentAttendance> attendances;

  const AttendanceLoadSuccess(this.attendances);

  @override
  List<Object?> get props => [attendances];
}

class AttendanceLoadFailure extends AttendanceState {
  final String message;

  const AttendanceLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
