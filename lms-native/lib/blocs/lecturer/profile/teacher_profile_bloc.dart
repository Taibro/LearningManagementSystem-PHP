import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/teacher_repository.dart';
import 'teacher_profile_event.dart';
import 'teacher_profile_state.dart';

class TeacherProfileBloc extends Bloc<TeacherProfileEvent, TeacherProfileState> {
  final TeacherRepository repository;

  TeacherProfileBloc(this.repository) : super(TeacherProfileInitial()) {
    on<TeacherProfileFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    TeacherProfileFetchRequested event,
    Emitter<TeacherProfileState> emit,
  ) async {
    emit(TeacherProfileLoading());
    try {
      final profile = await repository.getProfile();
      emit(TeacherProfileLoadSuccess(profile));
    } catch (e) {
      emit(TeacherProfileLoadFailure(e.toString()));
    }
  }
}
