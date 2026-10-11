import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/teacher_repository.dart';
import 'teacher_salary_event.dart';
import 'teacher_salary_state.dart';

class TeacherSalaryBloc extends Bloc<TeacherSalaryEvent, TeacherSalaryState> {
  final TeacherRepository repository;

  TeacherSalaryBloc(this.repository) : super(TeacherSalaryInitial()) {
    on<TeacherSalaryFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    TeacherSalaryFetchRequested event,
    Emitter<TeacherSalaryState> emit,
  ) async {
    emit(TeacherSalaryLoading());
    try {
      final salary = await repository.getMonthlySalary(event.year, event.month);
      emit(TeacherSalaryLoadSuccess(salary));
    } catch (e) {
      emit(TeacherSalaryLoadFailure(e.toString()));
    }
  }
}
