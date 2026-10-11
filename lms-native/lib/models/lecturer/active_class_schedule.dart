class ActiveClassSchedule {
  final int? classId;
  final String? classCode;
  final String? courseName;
  final List<ScheduleDetail>? schedules;

  ActiveClassSchedule({
    this.classId,
    this.classCode,
    this.courseName,
    this.schedules,
  });

  factory ActiveClassSchedule.fromJson(Map<String, dynamic> json) {
    return ActiveClassSchedule(
      classId: json['classId'],
      classCode: json['classCode'],
      courseName: json['courseName'],
      schedules: json['schedules'] != null
          ? (json['schedules'] as List)
              .map((e) => ScheduleDetail.fromJson(e))
              .toList()
          : null,
    );
  }
}

class ScheduleDetail {
  final int? scheduleId;
  final int? dayOfWeek;
  final int? startPeriod;
  final int? endPeriod;
  final String? roomName;

  ScheduleDetail({
    this.scheduleId,
    this.dayOfWeek,
    this.startPeriod,
    this.endPeriod,
    this.roomName,
  });

  factory ScheduleDetail.fromJson(Map<String, dynamic> json) {
    return ScheduleDetail(
      scheduleId: json['scheduleId'],
      dayOfWeek: json['dayOfWeek'],
      startPeriod: json['startPeriod'],
      endPeriod: json['endPeriod'],
      roomName: json['roomName'],
    );
  }
}
