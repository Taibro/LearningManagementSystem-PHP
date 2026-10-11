class AdminTeacher {
  final int? id;
  final String? fullName;
  final String? teacherCode;
  final String? specialization;
  final String? departmentName;

  AdminTeacher({
    this.id,
    this.fullName,
    this.teacherCode,
    this.specialization,
    this.departmentName,
  });

  factory AdminTeacher.fromJson(Map<String, dynamic> json) {
    return AdminTeacher(
      id: json['id'],
      fullName: json['fullName'],
      teacherCode: json['teacherCode'],
      specialization: json['specialization'],
      departmentName: json['departmentName'],
    );
  }
}
