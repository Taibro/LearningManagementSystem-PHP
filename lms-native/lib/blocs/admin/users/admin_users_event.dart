import 'package:equatable/equatable.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object> get props => [];
}

class AdminUsersFetchRequested extends AdminUsersEvent {
  const AdminUsersFetchRequested();
}
