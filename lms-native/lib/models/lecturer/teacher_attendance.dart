class AttendanceDetail {
  final String? studentCode;
  final String? studentName;
  String? attendanceStatus;
  String? notes;

  AttendanceDetail({
    this.studentCode,
    this.studentName,
    this.attendanceStatus,
    this.notes,
  });

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceDetail(
      studentCode: json['studentCode'],
      studentName: json['studentName'],
      attendanceStatus: json['attendanceStatus'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentCode': studentCode,
      'attendanceStatus': attendanceStatus,
      'notes': notes,
    };
  }
}

class TeacherAttendanceList {
  final int? classId;
  final String? subjectName;
  final int? scheduleId;
  final String? sessionDate;
  final List<AttendanceDetail>? students;

  TeacherAttendanceList({
    this.classId,
    this.subjectName,
    this.scheduleId,
    this.sessionDate,
    this.students,
  });

  factory TeacherAttendanceList.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceList(
      classId: json['classId'],
      subjectName: json['subjectName'],
      scheduleId: json['scheduleId'],
      sessionDate: json['sessionDate'],
      students: json['students'] != null
          ? (json['students'] as List)
              .map((e) => AttendanceDetail.fromJson(e))
              .toList()
          : null,
    );
  }
}
