import 'package:equatable/equatable.dart';
import '../../../models/admin/admin_class.dart';
import '../../../models/admin/admin_dashboard_stats.dart';

abstract class AdminReportsState extends Equatable {
  const AdminReportsState();
  
  @override
  List<Object> get props => [];
}

class AdminReportsInitial extends AdminReportsState {}

class AdminReportsLoading extends AdminReportsState {}

class AdminReportsLoadSuccess extends AdminReportsState {
  final List<AdminClass> classes;
  final AdminDashboardStats stats;

  const AdminReportsLoadSuccess({
    required this.classes,
    required this.stats,
  });

  @override
  List<Object> get props => [classes, stats];
}

class AdminReportsLoadFailure extends AdminReportsState {
  final String error;

  const AdminReportsLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}
