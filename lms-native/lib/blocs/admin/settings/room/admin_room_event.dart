import 'package:equatable/equatable.dart';

abstract class AdminRoomEvent extends Equatable {
  const AdminRoomEvent();

  @override
  List<Object?> get props => [];
}

class AdminRoomFetchRequested extends AdminRoomEvent {}

class AdminRoomCreated extends AdminRoomEvent {
  final String roomNumber;
  final int capacity;
  final bool isActive;
  final int schoolBranchId;

  const AdminRoomCreated({
    required this.roomNumber,
    required this.capacity,
    required this.isActive,
    required this.schoolBranchId,
  });

  @override
  List<Object?> get props => [roomNumber, capacity, isActive, schoolBranchId];
}
