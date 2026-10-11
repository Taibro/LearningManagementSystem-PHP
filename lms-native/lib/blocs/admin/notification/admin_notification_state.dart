import '../../../models/admin/notification_response.dart';

abstract class AdminNotificationState {
  const AdminNotificationState();
}

class AdminNotificationInitial extends AdminNotificationState {}

class AdminNotificationLoading extends AdminNotificationState {}

class AdminNotificationLoadSuccess extends AdminNotificationState {
  final List<NotificationResponse> notifications;
  const AdminNotificationLoadSuccess(this.notifications);
}

class AdminNotificationLoadFailure extends AdminNotificationState {
  final String message;
  const AdminNotificationLoadFailure(this.message);
}

class AdminNotificationActionSuccess extends AdminNotificationState {
  final String message;
  const AdminNotificationActionSuccess(this.message);
}

class AdminNotificationActionFailure extends AdminNotificationState {
  final String message;
  const AdminNotificationActionFailure(this.message);
}
