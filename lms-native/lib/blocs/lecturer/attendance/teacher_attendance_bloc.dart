import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/teacher_repository.dart';
import 'teacher_attendance_event.dart';
import 'teacher_attendance_state.dart';

class TeacherAttendanceBloc extends Bloc<TeacherAttendanceEvent, TeacherAttendanceState> {
  final TeacherRepository repository;

  TeacherAttendanceBloc(this.repository) : super(TeacherAttendanceInitial()) {
    on<TeacherAttendanceFetchRequested>(_onFetchRequested);
    on<TeacherAttendanceSaveRequested>(_onSaveRequested);
  }

  Future<void> _onFetchRequested(
    TeacherAttendanceFetchRequested event,
    Emitter<TeacherAttendanceState> emit,
  ) async {
    emit(TeacherAttendanceLoading());
    try {
      final attendanceList = await repository.getAttendanceList(
        event.classId,
        event.scheduleId,
        event.date,
      );
      emit(TeacherAttendanceLoadSuccess(attendanceList));
    } catch (e) {
      emit(TeacherAttendanceLoadFailure(e.toString()));
    }
  }

  Future<void> _onSaveRequested(
    TeacherAttendanceSaveRequested event,
    Emitter<TeacherAttendanceState> emit,
  ) async {
    // Preserve current list state to revert or keep showing if needed
    // However, save attendance might be better handled by just yielding Success/Failure without clearing the list
    try {
      await repository.saveAttendance({
        'classId': event.classId,
        'scheduleId': event.scheduleId,
        'sessionDate': event.sessionDate,
        'studentCode': event.studentCode,
        'attendanceStatus': event.status,
        'notes': event.notes,
      });
      // emit(TeacherAttendanceSaveSuccess());
      // For a better UX, we just let it succeed silently or show a toast via UI.
    } catch (e) {
      // emit(TeacherAttendanceSaveFailure(e.toString()));
      throw Exception('Save failed: $e');
    }
  }
}
