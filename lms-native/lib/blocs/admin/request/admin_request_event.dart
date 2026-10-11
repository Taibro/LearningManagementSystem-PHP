abstract class AdminRequestEvent {
  const AdminRequestEvent();
}

class AdminRequestFetchPending extends AdminRequestEvent {
  const AdminRequestFetchPending();
}

class AdminRequestApprove extends AdminRequestEvent {
  final int id;
  const AdminRequestApprove(this.id);
}

class AdminRequestReject extends AdminRequestEvent {
  final int id;
  final String adminNote;
  const AdminRequestReject(this.id, this.adminNote);
}
