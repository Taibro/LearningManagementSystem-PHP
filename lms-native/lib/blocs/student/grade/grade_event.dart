import 'package:equatable/equatable.dart';

abstract class GradeEvent extends Equatable {
  const GradeEvent();

  @override
  List<Object?> get props => [];
}

class GradeFetchRequested extends GradeEvent {}
