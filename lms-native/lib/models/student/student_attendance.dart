class StudentAttendance {
  final String? semesterName;
  final String? classCode;
  final String? courseName;
  final int? credits;
  final int? absentWithPermission;
  final int? absentWithoutPermission;
  final int? late;

  StudentAttendance({
    this.semesterName,
    this.classCode,
    this.courseName,
    this.credits,
    this.absentWithPermission,
    this.absentWithoutPermission,
    this.late,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      semesterName: json['semesterName'],
      classCode: json['classCode'],
      courseName: json['courseName'],
      credits: json['credits'],
      absentWithPermission: json['absentWithPermission'],
      absentWithoutPermission: json['absentWithoutPermission'],
      late: json['late'],
    );
  }
}
