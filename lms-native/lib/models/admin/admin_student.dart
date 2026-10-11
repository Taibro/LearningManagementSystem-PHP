class AdminStudent {
  final int? id;
  final String? fullName;
  final String? studentCode;
  final String? className;
  final String? major;

  AdminStudent({
    this.id,
    this.fullName,
    this.studentCode,
    this.className,
    this.major,
  });

  factory AdminStudent.fromJson(Map<String, dynamic> json) {
    return AdminStudent(
      id: json['id'],
      fullName: json['fullName'],
      studentCode: json['studentCode'],
      className: json['className'],
      major: json['major'],
    );
  }
}
