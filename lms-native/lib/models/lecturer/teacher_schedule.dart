class TeacherSchedule {
  final String? courseName;
  final String? classCode;
  final String? roomName;
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? sessionType;
  final int? startPeriod;
  final int? endPeriod;

  TeacherSchedule({
    this.courseName,
    this.classCode,
    this.roomName,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.sessionType,
    this.startPeriod,
    this.endPeriod,
  });

  factory TeacherSchedule.fromJson(Map<String, dynamic> json) {
    return TeacherSchedule(
      courseName: json['courseName'],
      classCode: json['classCode'],
      roomName: json['roomName'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      sessionType: json['sessionType'],
      startPeriod: json['startPeriod'],
      endPeriod: json['endPeriod'],
    );
  }
}
