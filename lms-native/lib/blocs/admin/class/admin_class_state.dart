import 'package:equatable/equatable.dart';
import '../../../models/admin/admin_class.dart';

abstract class AdminClassState extends Equatable {
  const AdminClassState();
  
  @override
  List<Object> get props => [];
}

class AdminClassInitial extends AdminClassState {}

class AdminClassLoading extends AdminClassState {}

class AdminClassLoadSuccess extends AdminClassState {
  final List<AdminClass> classes;

  const AdminClassLoadSuccess(this.classes);

  @override
  List<Object> get props => [classes];
}

class AdminClassLoadFailure extends AdminClassState {
  final String error;

  const AdminClassLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}
