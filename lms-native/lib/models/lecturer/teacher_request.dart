class TeacherRequest {
  final int? id;
  final String? type; // tamNgung, dayBu, dayThay
  final String? classInfo; // Mã lớp
  final String? date;
  final String? reason;
  final String? status; // approved, pending, rejected

  TeacherRequest({
    this.id,
    this.type,
    this.classInfo,
    this.date,
    this.reason,
    this.status,
  });

  factory TeacherRequest.fromJson(Map<String, dynamic> json) {
    return TeacherRequest(
      id: json['id'],
      type: json['type'],
      classInfo: json['classInfo'] ?? json['class'],
      date: json['date'],
      reason: json['reason'],
      status: json['status'],
    );
  }
}
