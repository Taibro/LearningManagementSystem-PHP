import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/school_admin_repository.dart';
import 'admin_room_event.dart';
import 'admin_room_state.dart';

class AdminRoomBloc extends Bloc<AdminRoomEvent, AdminRoomState> {
  final SchoolAdminRepository _repository;

  AdminRoomBloc(this._repository) : super(AdminRoomInitial()) {
    on<AdminRoomFetchRequested>(_onFetchRequested);
    on<AdminRoomCreated>(_onRoomCreated);
  }

  Future<void> _onFetchRequested(
    AdminRoomFetchRequested event,
    Emitter<AdminRoomState> emit,
  ) async {
    emit(AdminRoomLoadInProgress());
    try {
      final rooms = await _repository.getAllRooms();
      emit(AdminRoomLoadSuccess(rooms));
    } catch (e) {
      emit(AdminRoomLoadFailure(e.toString()));
    }
  }

  Future<void> _onRoomCreated(
    AdminRoomCreated event,
    Emitter<AdminRoomState> emit,
  ) async {
    emit(AdminRoomActionInProgress());
    try {
      final request = {
        'roomNumber': event.roomNumber,
        'capacity': event.capacity,
        'isActive': event.isActive,
        'schoolBranchId': event.schoolBranchId,
        'roomType': 'CLASSROOM', // default to CLASSROOM
      };
      final room = await _repository.createRoom(request);
      emit(AdminRoomActionSuccess('Tạo phòng học thành công', room));
      add(AdminRoomFetchRequested()); // Refresh list
    } catch (e) {
      emit(AdminRoomActionFailure(e.toString()));
    }
  }
}
