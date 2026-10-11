import 'package:equatable/equatable.dart';
import '../../../models/lecturer/teaching_statistic.dart';

abstract class TeacherStatisticState extends Equatable {
  const TeacherStatisticState();

  @override
  List<Object?> get props => [];
}

class TeacherStatisticInitial extends TeacherStatisticState {}

class TeacherStatisticLoading extends TeacherStatisticState {}

class TeacherStatisticLoadSuccess extends TeacherStatisticState {
  final TeachingStatistic statistic;

  const TeacherStatisticLoadSuccess(this.statistic);

  @override
  List<Object?> get props => [statistic];
}

class TeacherStatisticLoadFailure extends TeacherStatisticState {
  final String message;

  const TeacherStatisticLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
