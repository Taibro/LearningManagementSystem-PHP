class AdminClass {
  final int? id;
  final String? code;
  final String? courseName;
  final String? semesterName;
  final int? enrolledStudents;
  final int? maxStudents;

  AdminClass({
    this.id,
    this.code,
    this.courseName,
    this.semesterName,
    this.enrolledStudents,
    this.maxStudents,
  });

  factory AdminClass.fromJson(Map<String, dynamic> json) {
    return AdminClass(
      id: json['id'],
      code: json['code'],
      courseName: json['courseName'],
      semesterName: json['semesterName'],
      enrolledStudents: json['enrolledStudents'],
      maxStudents: json['maxStudents'],
    );
  }
}
