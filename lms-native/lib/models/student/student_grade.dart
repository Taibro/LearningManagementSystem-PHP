class StudentGrade {
  final String? semesterName;
  final String? courseCode;
  final String? courseName;
  final String? classCode;
  final int? credits;
  final double? gradeAttendance;
  final double? gradeMidterm;
  final double? gradeFinal;
  final double? gradeTotal;
  final String? gradeLetter;
  final String? enrollmentStatus;

  StudentGrade({
    this.semesterName,
    this.courseCode,
    this.courseName,
    this.classCode,
    this.credits,
    this.gradeAttendance,
    this.gradeMidterm,
    this.gradeFinal,
    this.gradeTotal,
    this.gradeLetter,
    this.enrollmentStatus,
  });

  factory StudentGrade.fromJson(Map<String, dynamic> json) {
    return StudentGrade(
      semesterName: json['semesterName'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      classCode: json['classCode'],
      credits: json['credits'],
      gradeAttendance: json['gradeAttendance']?.toDouble(),
      gradeMidterm: json['gradeMidterm']?.toDouble(),
      gradeFinal: json['gradeFinal']?.toDouble(),
      gradeTotal: json['gradeTotal']?.toDouble(),
      gradeLetter: json['gradeLetter'],
      enrollmentStatus: json['enrollmentStatus'],
    );
  }
}
