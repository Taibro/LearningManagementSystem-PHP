import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/school_admin_repository.dart';
import 'admin_notification_event.dart';
import 'admin_notification_state.dart';

class AdminNotificationBloc extends Bloc<AdminNotificationEvent, AdminNotificationState> {
  final SchoolAdminRepository _repository;

  AdminNotificationBloc(this._repository) : super(AdminNotificationInitial()) {
    on<AdminNotificationFetchAll>(_onFetchAll);
    on<AdminNotificationCreate>(_onCreate);
    on<AdminNotificationBroadcast>(_onBroadcast);
  }

  Future<void> _onFetchAll(
      AdminNotificationFetchAll event, Emitter<AdminNotificationState> emit) async {
    emit(AdminNotificationLoading());
    try {
      final notifications = await _repository.getAllNotifications();
      emit(AdminNotificationLoadSuccess(notifications));
    } catch (e) {
      emit(AdminNotificationLoadFailure(e.toString()));
    }
  }

  Future<void> _onCreate(
      AdminNotificationCreate event, Emitter<AdminNotificationState> emit) async {
    try {
      await _repository.createNotification(event.request);
      emit(const AdminNotificationActionSuccess('Đã gửi thông báo thành công'));
      add(const AdminNotificationFetchAll()); // Reload
    } catch (e) {
      emit(AdminNotificationActionFailure(e.toString()));
    }
  }

  Future<void> _onBroadcast(
      AdminNotificationBroadcast event, Emitter<AdminNotificationState> emit) async {
    try {
      await _repository.broadcastNotification(event.request);
      emit(const AdminNotificationActionSuccess('Đã gửi thông báo hàng loạt thành công'));
      add(const AdminNotificationFetchAll()); // Reload
    } catch (e) {
      emit(AdminNotificationActionFailure(e.toString()));
    }
  }
}
