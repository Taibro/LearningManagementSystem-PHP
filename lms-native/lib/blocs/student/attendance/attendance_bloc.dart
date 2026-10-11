import 'package:flutter_bloc/flutter_bloc.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';
import '../../../repositories/student_repository.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final StudentRepository _studentRepository;

  AttendanceBloc(this._studentRepository) : super(AttendanceInitial()) {
    on<AttendanceFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    AttendanceFetchRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendances = await _studentRepository.getAttendance();
      emit(AttendanceLoadSuccess(attendances));
    } catch (e) {
      emit(AttendanceLoadFailure(e.toString()));
    }
  }
}
