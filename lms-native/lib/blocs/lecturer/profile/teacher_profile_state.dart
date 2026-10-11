import 'package:equatable/equatable.dart';
import '../../../models/lecturer/teacher_profile.dart';

abstract class TeacherProfileState extends Equatable {
  const TeacherProfileState();

  @override
  List<Object?> get props => [];
}

class TeacherProfileInitial extends TeacherProfileState {}

class TeacherProfileLoading extends TeacherProfileState {}

class TeacherProfileLoadSuccess extends TeacherProfileState {
  final TeacherProfile profile;

  const TeacherProfileLoadSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class TeacherProfileLoadFailure extends TeacherProfileState {
  final String message;

  const TeacherProfileLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
