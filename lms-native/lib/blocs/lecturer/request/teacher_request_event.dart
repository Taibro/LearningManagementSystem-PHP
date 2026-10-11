import 'package:equatable/equatable.dart';

abstract class TeacherRequestEvent extends Equatable {
  const TeacherRequestEvent();

  @override
  List<Object?> get props => [];
}

class TeacherRequestFetchRequested extends TeacherRequestEvent {}

class TeacherRequestCreateRequested extends TeacherRequestEvent {
  final Map<String, dynamic> data;

  const TeacherRequestCreateRequested({required this.data});

  @override
  List<Object?> get props => [data];
}
