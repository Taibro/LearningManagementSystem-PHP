import '../../../models/admin/schedule_exception_response.dart';

abstract class AdminRequestState {
  const AdminRequestState();
}

class AdminRequestInitial extends AdminRequestState {}

class AdminRequestLoading extends AdminRequestState {}

class AdminRequestLoadSuccess extends AdminRequestState {
  final List<ScheduleExceptionResponse> pendingRequests;
  const AdminRequestLoadSuccess(this.pendingRequests);
}

class AdminRequestLoadFailure extends AdminRequestState {
  final String message;
  const AdminRequestLoadFailure(this.message);
}

class AdminRequestActionSuccess extends AdminRequestState {
  final String message;
  const AdminRequestActionSuccess(this.message);
}

class AdminRequestActionFailure extends AdminRequestState {
  final String message;
  const AdminRequestActionFailure(this.message);
}
