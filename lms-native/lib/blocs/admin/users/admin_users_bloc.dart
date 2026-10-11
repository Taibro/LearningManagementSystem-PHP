import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/admin_repository.dart';
import '../../../models/admin/admin_student.dart';
import '../../../models/admin/admin_teacher.dart';
import 'admin_users_event.dart';
import 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final AdminRepository _repository;

  AdminUsersBloc(this._repository) : super(AdminUsersInitial()) {
    on<AdminUsersFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
      AdminUsersFetchRequested event, Emitter<AdminUsersState> emit) async {
    emit(AdminUsersLoading());
    try {
      final results = await Future.wait([
        _repository.getAllStudents(),
        _repository.getAllTeachers(),
      ]);
      
      emit(AdminUsersLoadSuccess(
        students: results[0] as List<AdminStudent>,
        teachers: results[1] as List<AdminTeacher>,
      ));
    } catch (e) {
      emit(AdminUsersLoadFailure(e.toString()));
    }
  }
}
