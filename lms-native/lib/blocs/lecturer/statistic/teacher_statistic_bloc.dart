import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/teacher_repository.dart';
import 'teacher_statistic_event.dart';
import 'teacher_statistic_state.dart';

class TeacherStatisticBloc extends Bloc<TeacherStatisticEvent, TeacherStatisticState> {
  final TeacherRepository repository;

  TeacherStatisticBloc(this.repository) : super(TeacherStatisticInitial()) {
    on<TeacherStatisticFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    TeacherStatisticFetchRequested event,
    Emitter<TeacherStatisticState> emit,
  ) async {
    emit(TeacherStatisticLoading());
    try {
      final statistic = await repository.getDashboardStatistics();
      emit(TeacherStatisticLoadSuccess(statistic));
    } catch (e) {
      emit(TeacherStatisticLoadFailure(e.toString()));
    }
  }
}
