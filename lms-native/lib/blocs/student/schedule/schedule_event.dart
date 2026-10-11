import 'package:equatable/equatable.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleFetchRequested extends ScheduleEvent {
  final String? date; // Format: YYYY-MM-DD

  const ScheduleFetchRequested({this.date});

  @override
  List<Object?> get props => [date];
}
