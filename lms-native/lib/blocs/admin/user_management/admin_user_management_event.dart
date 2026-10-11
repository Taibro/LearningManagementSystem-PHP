abstract class AdminUserManagementEvent {
  const AdminUserManagementEvent();
}

class AdminUserManagementCreateStudent extends AdminUserManagementEvent {
  final Map<String, dynamic> request;
  const AdminUserManagementCreateStudent(this.request);
}

class AdminUserManagementCreateTeacher extends AdminUserManagementEvent {
  final Map<String, dynamic> request;
  const AdminUserManagementCreateTeacher(this.request);
}

class AdminUserManagementCreateClass extends AdminUserManagementEvent {
  final Map<String, dynamic> request;
  const AdminUserManagementCreateClass(this.request);
}
