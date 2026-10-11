import 'package:equatable/equatable.dart';
import '../../../models/admin/semester.dart';

abstract class AdminSemesterEvent extends Equatable {
  const AdminSemesterEvent();

  @override
  List<Object?> get props => [];
}

class AdminSemesterFetchRequested extends AdminSemesterEvent {
  const AdminSemesterFetchRequested();
}

class AdminSemesterCreated extends AdminSemesterEvent {
  final String name;
  final String startDate;
  final String endDate;
  final String academicYearName;
  final int schoolId;

  const AdminSemesterCreated({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.academicYearName,
    required this.schoolId,
  });

  @override
  List<Object?> get props => [name, startDate, endDate, academicYearName, schoolId];
}

class AdminSemesterEnded extends AdminSemesterEvent {
  final Semester semester;

  const AdminSemesterEnded(this.semester);

  @override
  List<Object?> get props => [semester];
}
