import 'package:equatable/equatable.dart';
import '../../../models/lecturer/monthly_salary.dart';

abstract class TeacherSalaryState extends Equatable {
  const TeacherSalaryState();

  @override
  List<Object?> get props => [];
}

class TeacherSalaryInitial extends TeacherSalaryState {}

class TeacherSalaryLoading extends TeacherSalaryState {}

class TeacherSalaryLoadSuccess extends TeacherSalaryState {
  final MonthlySalary salary;

  const TeacherSalaryLoadSuccess(this.salary);

  @override
  List<Object?> get props => [salary];
}

class TeacherSalaryLoadFailure extends TeacherSalaryState {
  final String message;

  const TeacherSalaryLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
