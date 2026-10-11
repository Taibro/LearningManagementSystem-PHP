import 'package:equatable/equatable.dart';
import '../../../models/student/student_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final StudentProfile profile;

  const ProfileLoadSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileLoadFailure extends ProfileState {
  final String message;

  const ProfileLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
