import 'package:equatable/equatable.dart';
import '../../../models/admin/semester.dart';

abstract class AdminSemesterState extends Equatable {
  const AdminSemesterState();

  @override
  List<Object?> get props => [];
}

class AdminSemesterInitial extends AdminSemesterState {}

class AdminSemesterLoading extends AdminSemesterState {}

class AdminSemesterLoadSuccess extends AdminSemesterState {
  final Semester? currentSemester;
  final List<Semester> pastSemesters;

  const AdminSemesterLoadSuccess({
    required this.currentSemester,
    required this.pastSemesters,
  });

  @override
  List<Object?> get props => [currentSemester, pastSemesters];
}

class AdminSemesterLoadFailure extends AdminSemesterState {
  final String error;

  const AdminSemesterLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AdminSemesterActionInProgress extends AdminSemesterState {}

class AdminSemesterActionSuccess extends AdminSemesterState {
  final String message;

  const AdminSemesterActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminSemesterActionFailure extends AdminSemesterState {
  final String error;

  const AdminSemesterActionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
