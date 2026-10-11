import 'package:equatable/equatable.dart';
import '../../../models/student/student_grade.dart';

abstract class GradeState extends Equatable {
  const GradeState();

  @override
  List<Object?> get props => [];
}

class GradeInitial extends GradeState {}

class GradeLoading extends GradeState {}

class GradeLoadSuccess extends GradeState {
  final List<StudentGrade> grades;

  const GradeLoadSuccess(this.grades);

  @override
  List<Object?> get props => [grades];
}

class GradeLoadFailure extends GradeState {
  final String message;

  const GradeLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
