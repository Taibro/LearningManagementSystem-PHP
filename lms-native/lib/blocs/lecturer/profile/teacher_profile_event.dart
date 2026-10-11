import 'package:equatable/equatable.dart';

abstract class TeacherProfileEvent extends Equatable {
  const TeacherProfileEvent();

  @override
  List<Object?> get props => [];
}

class TeacherProfileFetchRequested extends TeacherProfileEvent {}
