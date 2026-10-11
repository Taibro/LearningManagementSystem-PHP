class StudentSchedule {
  final String? courseName;
  final String? courseCode;
  final String? classCode;
  final String? roomName;
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? sessionType;
  final int? startPeriod;
  final int? endPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? teacherName;
  final int? credits;
  final String? exceptionType;
  final String? substituteStatus;
  final String? substituteTeacherName;
  final String? makeupStatus;
  final DateTime? exceptionDate;
  final DateTime? replacementDate;
  final int? replacementStartPeriod;
  final int? replacementEndPeriod;
  final String? replacementRoomName;
  final String? attendanceStatus;

  StudentSchedule({
    this.courseName,
    this.courseCode,
    this.classCode,
    this.roomName,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.sessionType,
    this.startPeriod,
    this.endPeriod,
    this.startDate,
    this.endDate,
    this.teacherName,
    this.credits,
    this.exceptionType,
    this.substituteStatus,
    this.substituteTeacherName,
    this.makeupStatus,
    this.exceptionDate,
    this.replacementDate,
    this.replacementStartPeriod,
    this.replacementEndPeriod,
    this.replacementRoomName,
    this.attendanceStatus,
  });

  factory StudentSchedule.fromJson(Map<String, dynamic> json) {
    return StudentSchedule(
      courseName: json['courseName'],
      courseCode: json['courseCode'],
      classCode: json['classCode'],
      roomName: json['roomName'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      sessionType: json['sessionType'],
      startPeriod: json['startPeriod'],
      endPeriod: json['endPeriod'],
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      teacherName: json['teacherName'],
      credits: json['credits'],
      exceptionType: json['exceptionType'],
      substituteStatus: json['substituteStatus'],
      substituteTeacherName: json['substituteTeacherName'],
      makeupStatus: json['makeupStatus'],
      exceptionDate: json['exceptionDate'] != null
          ? DateTime.tryParse(json['exceptionDate'])
          : null,
      replacementDate: json['replacementDate'] != null
          ? DateTime.tryParse(json['replacementDate'])
          : null,
      replacementStartPeriod: json['replacementStartPeriod'],
      replacementEndPeriod: json['replacementEndPeriod'],
      replacementRoomName: json['replacementRoomName'],
      attendanceStatus: json['attendanceStatus'],
    );
  }
}
