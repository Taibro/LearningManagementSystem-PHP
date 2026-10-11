import 'package:equatable/equatable.dart';

abstract class AdminReportsEvent extends Equatable {
  const AdminReportsEvent();

  @override
  List<Object> get props => [];
}

class AdminReportsFetchRequested extends AdminReportsEvent {
  const AdminReportsFetchRequested();
}
