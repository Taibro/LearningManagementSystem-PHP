import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/admin_repository.dart';
import '../../../models/admin/admin_class.dart';
import '../../../models/admin/admin_dashboard_stats.dart';
import 'admin_reports_event.dart';
import 'admin_reports_state.dart';

class AdminReportsBloc extends Bloc<AdminReportsEvent, AdminReportsState> {
  final AdminRepository _repository;

  AdminReportsBloc(this._repository) : super(AdminReportsInitial()) {
    on<AdminReportsFetchRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
      AdminReportsFetchRequested event, Emitter<AdminReportsState> emit) async {
    emit(AdminReportsLoading());
    try {
      final results = await Future.wait([
        _repository.getAllClasses(),
        _repository.getDashboardStats(),
      ]);
      
      emit(AdminReportsLoadSuccess(
        classes: results[0] as List<AdminClass>,
        stats: results[1] as AdminDashboardStats,
      ));
    } catch (e) {
      emit(AdminReportsLoadFailure(e.toString()));
    }
  }
}
