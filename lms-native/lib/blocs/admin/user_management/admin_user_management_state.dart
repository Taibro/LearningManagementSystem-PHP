abstract class AdminUserManagementState {
  const AdminUserManagementState();
}

class AdminUserManagementInitial extends AdminUserManagementState {}

class AdminUserManagementLoading extends AdminUserManagementState {}

class AdminUserManagementSuccess extends AdminUserManagementState {
  final String message;
  const AdminUserManagementSuccess(this.message);
}

class AdminUserManagementFailure extends AdminUserManagementState {
  final String message;
  const AdminUserManagementFailure(this.message);
}
