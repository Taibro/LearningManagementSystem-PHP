import 'package:equatable/equatable.dart';
import '../../../../models/lecturer/teacher_request.dart';

abstract class TeacherRequestState extends Equatable {
  const TeacherRequestState();

  @override
  List<Object?> get props => [];
}

class TeacherRequestInitial extends TeacherRequestState {}

class TeacherRequestLoading extends TeacherRequestState {}

class TeacherRequestLoadSuccess extends TeacherRequestState {
  final List<TeacherRequest> requests;

  const TeacherRequestLoadSuccess(this.requests);

  @override
  List<Object?> get props => [requests];
}

class TeacherRequestLoadFailure extends TeacherRequestState {
  final String message;

  const TeacherRequestLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TeacherRequestCreateInProgress extends TeacherRequestState {}

class TeacherRequestCreateSuccess extends TeacherRequestState {
  final String message;

  const TeacherRequestCreateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TeacherRequestCreateFailure extends TeacherRequestState {
  final String message;

  const TeacherRequestCreateFailure(this.message);

  @override
  List<Object?> get props => [message];
}
