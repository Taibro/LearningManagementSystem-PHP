import 'package:flutter_bloc/flutter_bloc.dart';
import 'grade_event.dart';
import 'grade_state.dart';
import '../../../repositories/student_repository.dart';

class GradeBloc extends Bloc<GradeEvent, GradeState> {
  final StudentRepository _studentRepository;

  GradeBloc(this._studentRepository) : super(GradeInitial()) {
    on<GradeFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    GradeFetchRequested event,
    Emitter<GradeState> emit,
  ) async {
    emit(GradeLoading());
    try {
      final grades = await _studentRepository.getGrades();
      emit(GradeLoadSuccess(grades));
    } catch (e) {
      emit(GradeLoadFailure(e.toString()));
    }
  }
}
