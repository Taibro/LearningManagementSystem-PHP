import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../../repositories/student_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final StudentRepository _studentRepository;

  ProfileBloc(this._studentRepository) : super(ProfileInitial()) {
    on<ProfileFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    ProfileFetchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _studentRepository.getProfile();
      emit(ProfileLoadSuccess(profile));
    } catch (e) {
      emit(ProfileLoadFailure(e.toString()));
    }
  }
}
