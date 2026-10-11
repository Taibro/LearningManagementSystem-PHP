import 'package:equatable/equatable.dart';

abstract class TeacherStatisticEvent extends Equatable {
  const TeacherStatisticEvent();

  @override
  List<Object?> get props => [];
}

class TeacherStatisticFetchRequested extends TeacherStatisticEvent {}
