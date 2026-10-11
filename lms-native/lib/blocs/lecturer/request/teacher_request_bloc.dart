import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/teacher_repository.dart';
import 'teacher_request_event.dart';
import 'teacher_request_state.dart';

class TeacherRequestBloc extends Bloc<TeacherRequestEvent, TeacherRequestState> {
  final TeacherRepository repository;

  TeacherRequestBloc({required this.repository}) : super(TeacherRequestInitial()) {
    on<TeacherRequestFetchRequested>(_onFetchRequests);
    on<TeacherRequestCreateRequested>(_onCreateRequest);
  }

  Future<void> _onFetchRequests(
    TeacherRequestFetchRequested event,
    Emitter<TeacherRequestState> emit,
  ) async {
    emit(TeacherRequestLoading());
    try {
      final requests = await repository.getTeachingRequests();
      emit(TeacherRequestLoadSuccess(requests));
    } catch (e) {
      emit(TeacherRequestLoadFailure(e.toString()));
    }
  }

  Future<void> _onCreateRequest(
    TeacherRequestCreateRequested event,
    Emitter<TeacherRequestState> emit,
  ) async {
    emit(TeacherRequestCreateInProgress());
    try {
      await repository.createTeachingRequest(event.data);
      emit(const TeacherRequestCreateSuccess('Đề xuất đã được gửi thành công.'));
      add(TeacherRequestFetchRequested());
    } catch (e) {
      emit(TeacherRequestCreateFailure(e.toString()));
      add(TeacherRequestFetchRequested());
    }
  }
}
