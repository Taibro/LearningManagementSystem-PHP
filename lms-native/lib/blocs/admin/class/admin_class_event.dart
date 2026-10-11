import 'package:equatable/equatable.dart';

abstract class AdminClassEvent extends Equatable {
  const AdminClassEvent();

  @override
  List<Object> get props => [];
}

class AdminClassFetchRequested extends AdminClassEvent {
  const AdminClassFetchRequested();
}
