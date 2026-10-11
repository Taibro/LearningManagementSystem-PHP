import 'package:equatable/equatable.dart';

abstract class TeacherSalaryEvent extends Equatable {
  const TeacherSalaryEvent();

  @override
  List<Object?> get props => [];
}

class TeacherSalaryFetchRequested extends TeacherSalaryEvent {
  final int year;
  final int month;

  const TeacherSalaryFetchRequested({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}
