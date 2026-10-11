import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/school_admin_repository.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final SchoolAdminRepository _repository;

  AdminDashboardBloc(this._repository) : super(AdminDashboardInitial()) {
    on<AdminDashboardFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
      AdminDashboardFetchRequested event, Emitter<AdminDashboardState> emit) async {
    emit(AdminDashboardLoading());
    try {
      final stats = await _repository.getDashboardStats();
      emit(AdminDashboardLoadSuccess(stats));
    } catch (e) {
      emit(AdminDashboardLoadFailure(e.toString()));
    }
  }
}
