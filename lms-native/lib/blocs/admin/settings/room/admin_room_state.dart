import 'package:equatable/equatable.dart';
import '../../../../models/admin/room.dart';

abstract class AdminRoomState extends Equatable {
  const AdminRoomState();
  
  @override
  List<Object?> get props => [];
}

class AdminRoomInitial extends AdminRoomState {}

class AdminRoomLoadInProgress extends AdminRoomState {}

class AdminRoomLoadSuccess extends AdminRoomState {
  final List<Room> rooms;

  const AdminRoomLoadSuccess(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class AdminRoomLoadFailure extends AdminRoomState {
  final String message;

  const AdminRoomLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminRoomActionInProgress extends AdminRoomState {}

class AdminRoomActionSuccess extends AdminRoomState {
  final String message;
  final Room room;

  const AdminRoomActionSuccess(this.message, this.room);

  @override
  List<Object?> get props => [message, room];
}

class AdminRoomActionFailure extends AdminRoomState {
  final String message;

  const AdminRoomActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
