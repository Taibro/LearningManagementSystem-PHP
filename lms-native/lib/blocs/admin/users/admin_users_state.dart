import 'package:equatable/equatable.dart';
import '../../../models/admin/admin_student.dart';
import '../../../models/admin/admin_teacher.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();
  
  @override
  List<Object> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoadSuccess extends AdminUsersState {
  final List<AdminStudent> students;
  final List<AdminTeacher> teachers;

  const AdminUsersLoadSuccess({
    required this.students,
    required this.teachers,
  });

  @override
  List<Object> get props => [students, teachers];
}

class AdminUsersLoadFailure extends AdminUsersState {
  final String error;

  const AdminUsersLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}
