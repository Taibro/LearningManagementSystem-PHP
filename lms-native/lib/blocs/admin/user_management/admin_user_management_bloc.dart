import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/school_admin_repository.dart';
import 'admin_user_management_event.dart';
import 'admin_user_management_state.dart';

class AdminUserManagementBloc extends Bloc<AdminUserManagementEvent, AdminUserManagementState> {
  final SchoolAdminRepository _repository;

  AdminUserManagementBloc(this._repository) : super(AdminUserManagementInitial()) {
    on<AdminUserManagementCreateStudent>(_onCreateStudent);
    on<AdminUserManagementCreateTeacher>(_onCreateTeacher);
    on<AdminUserManagementCreateClass>(_onCreateClass);
  }

  Future<void> _onCreateStudent(
      AdminUserManagementCreateStudent event, Emitter<AdminUserManagementState> emit) async {
    emit(AdminUserManagementLoading());
    try {
      await _repository.createStudent(event.request);
      emit(const AdminUserManagementSuccess('Tạo sinh viên thành công'));
    } catch (e) {
      emit(AdminUserManagementFailure(e.toString()));
    }
  }

  Future<void> _onCreateTeacher(
      AdminUserManagementCreateTeacher event, Emitter<AdminUserManagementState> emit) async {
    emit(AdminUserManagementLoading());
    try {
      await _repository.createTeacher(event.request);
      emit(const AdminUserManagementSuccess('Tạo giảng viên thành công'));
    } catch (e) {
      emit(AdminUserManagementFailure(e.toString()));
    }
  }

  Future<void> _onCreateClass(
      AdminUserManagementCreateClass event, Emitter<AdminUserManagementState> emit) async {
    emit(AdminUserManagementLoading());
    try {
      await _repository.createClass(event.request);
      emit(const AdminUserManagementSuccess('Tạo lớp học thành công'));
    } catch (e) {
      emit(AdminUserManagementFailure(e.toString()));
    }
  }
}
