class TeacherChatResponse {
  final int teacherId;
  final String teacherName;
  final String departmentName;
  final String email;

  TeacherChatResponse({
    required this.teacherId,
    required this.teacherName,
    required this.departmentName,
    required this.email,
  });

  factory TeacherChatResponse.fromJson(Map<String, dynamic> json) {
    return TeacherChatResponse(
      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',
      departmentName: json['departmentName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
