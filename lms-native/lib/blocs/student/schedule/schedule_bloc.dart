import 'package:flutter_bloc/flutter_bloc.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';
import '../../../repositories/student_repository.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final StudentRepository _studentRepository;

  ScheduleBloc(this._studentRepository) : super(ScheduleInitial()) {
    on<ScheduleFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    ScheduleFetchRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      final schedules = await _studentRepository.getWeeklySchedule(date: event.date);
      emit(ScheduleLoadSuccess(schedules));
    } catch (e) {
      emit(ScheduleLoadFailure(e.toString()));
    }
  }
}
