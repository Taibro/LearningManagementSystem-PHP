import '../../../models/admin/dashboard_stats.dart';

abstract class AdminDashboardState {
  const AdminDashboardState();
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoadSuccess extends AdminDashboardState {
  final DashboardStats stats;
  const AdminDashboardLoadSuccess(this.stats);
}

class AdminDashboardLoadFailure extends AdminDashboardState {
  final String message;
  const AdminDashboardLoadFailure(this.message);
}
