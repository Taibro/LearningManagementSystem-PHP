import 'package:equatable/equatable.dart';
import '../../../models/lecturer/teacher_material.dart';

abstract class TeacherMaterialState extends Equatable {
  const TeacherMaterialState();

  @override
  List<Object?> get props => [];
}

class TeacherMaterialInitial extends TeacherMaterialState {}

class TeacherMaterialLoading extends TeacherMaterialState {}

class TeacherMaterialLoadSuccess extends TeacherMaterialState {
  final List<TeacherMaterial> materials;

  const TeacherMaterialLoadSuccess(this.materials);

  @override
  List<Object?> get props => [materials];
}

class TeacherMaterialLoadFailure extends TeacherMaterialState {
  final String message;

  const TeacherMaterialLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TeacherMaterialUploadInProgress extends TeacherMaterialState {}

class TeacherMaterialUploadSuccess extends TeacherMaterialState {
  final String message;

  const TeacherMaterialUploadSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TeacherMaterialUploadFailure extends TeacherMaterialState {
  final String message;

  const TeacherMaterialUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
