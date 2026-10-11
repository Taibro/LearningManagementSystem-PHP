import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/school_admin_repository.dart';
import 'admin_request_event.dart';
import 'admin_request_state.dart';

class AdminRequestBloc extends Bloc<AdminRequestEvent, AdminRequestState> {
  final SchoolAdminRepository _repository;

  AdminRequestBloc(this._repository) : super(AdminRequestInitial()) {
    on<AdminRequestFetchPending>(_onFetchPending);
    on<AdminRequestApprove>(_onApprove);
    on<AdminRequestReject>(_onReject);
  }

  Future<void> _onFetchPending(
      AdminRequestFetchPending event, Emitter<AdminRequestState> emit) async {
    emit(AdminRequestLoading());
    try {
      final requests = await _repository.getPendingExceptions();
      emit(AdminRequestLoadSuccess(requests));
    } catch (e) {
      emit(AdminRequestLoadFailure(e.toString()));
    }
  }

  Future<void> _onApprove(
      AdminRequestApprove event, Emitter<AdminRequestState> emit) async {
    try {
      await _repository.approveException(event.id);
      emit(const AdminRequestActionSuccess('Đã duyệt yêu cầu thành công'));
      add(const AdminRequestFetchPending()); // Reload list
    } catch (e) {
      emit(AdminRequestActionFailure(e.toString()));
    }
  }

  Future<void> _onReject(
      AdminRequestReject event, Emitter<AdminRequestState> emit) async {
    try {
      await _repository.rejectException(event.id, event.adminNote);
      emit(const AdminRequestActionSuccess('Đã từ chối yêu cầu'));
      add(const AdminRequestFetchPending()); // Reload list
    } catch (e) {
      emit(AdminRequestActionFailure(e.toString()));
    }
  }
}
