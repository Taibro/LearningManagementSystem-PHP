import 'package:equatable/equatable.dart';

abstract class TeacherMaterialEvent extends Equatable {
  const TeacherMaterialEvent();

  @override
  List<Object?> get props => [];
}

class TeacherMaterialFetchRequested extends TeacherMaterialEvent {
  final int teacherId;

  const TeacherMaterialFetchRequested({required this.teacherId});

  @override
  List<Object?> get props => [teacherId];
}

class TeacherMaterialUploadRequested extends TeacherMaterialEvent {
  final dynamic request;
  final int teacherId;

  const TeacherMaterialUploadRequested({required this.request, required this.teacherId});

  @override
  List<Object?> get props => [request, teacherId];
}
