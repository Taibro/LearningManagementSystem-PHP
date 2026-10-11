class StudentSurvey {
  final int? classId;
  final String? classCode;
  final String? courseName;
  final String? courseCode;
  final String? semesterName;
  final String? teacherName;
  final int? isCompleted;

  StudentSurvey({
    this.classId,
    this.classCode,
    this.courseName,
    this.courseCode,
    this.semesterName,
    this.teacherName,
    this.isCompleted,
  });

  factory StudentSurvey.fromJson(Map<String, dynamic> json) {
    return StudentSurvey(
      classId: json['classId'],
      classCode: json['classCode'],
      courseName: json['courseName'],
      courseCode: json['courseCode'],
      semesterName: json['semesterName'],
      teacherName: json['teacherName'],
      isCompleted: json['isCompleted'],
    );
  }
}
