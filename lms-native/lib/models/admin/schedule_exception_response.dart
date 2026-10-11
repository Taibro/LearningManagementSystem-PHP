class ScheduleExceptionResponse {
  final int? id;
  final int? scheduleId;
  final String? scheduleDetails;
  final String? exceptionDate;
  final String? reason;
  final String? exceptionType;
  final String? replacementDate;
  final String? approvalStatus;
  final String? proofFileUrl;
  final int? replacementStartPeriod;
  final int? replacementEndPeriod;
  final String? suggestedRoom;
  final String? makeupNotes;
  final String? makeupStatus;
  final int? substituteTeacherId;
  final String? substituteTeacherName;
  final String? substituteContent;
  final String? substituteStatus;
  final int? replacementRoomId;
  final String? replacementRoomNumber;
  final String? adminNote;
  final String? teacherCode;
  final String? teacherName;
  final String? classCode;
  final String? courseName;

  ScheduleExceptionResponse({
    this.id,
    this.scheduleId,
    this.scheduleDetails,
    this.exceptionDate,
    this.reason,
    this.exceptionType,
    this.replacementDate,
    this.approvalStatus,
    this.proofFileUrl,
    this.replacementStartPeriod,
    this.replacementEndPeriod,
    this.suggestedRoom,
    this.makeupNotes,
    this.makeupStatus,
    this.substituteTeacherId,
    this.substituteTeacherName,
    this.substituteContent,
    this.substituteStatus,
    this.replacementRoomId,
    this.replacementRoomNumber,
    this.adminNote,
    this.teacherCode,
    this.teacherName,
    this.classCode,
    this.courseName,
  });

  factory ScheduleExceptionResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleExceptionResponse(
      id: json['id'],
      scheduleId: json['scheduleId'],
      scheduleDetails: json['scheduleDetails'],
      exceptionDate: json['exceptionDate'],
      reason: json['reason'],
      exceptionType: json['exceptionType'],
      replacementDate: json['replacementDate'],
      approvalStatus: json['approvalStatus'],
      proofFileUrl: json['proofFileUrl'],
      replacementStartPeriod: json['replacementStartPeriod'],
      replacementEndPeriod: json['replacementEndPeriod'],
      suggestedRoom: json['suggestedRoom'],
      makeupNotes: json['makeupNotes'],
      makeupStatus: json['makeupStatus'],
      substituteTeacherId: json['substituteTeacherId'],
      substituteTeacherName: json['substituteTeacherName'],
      substituteContent: json['substituteContent'],
      substituteStatus: json['substituteStatus'],
      replacementRoomId: json['replacementRoomId'],
      replacementRoomNumber: json['replacementRoomNumber'],
      adminNote: json['adminNote'],
      teacherCode: json['teacherCode'],
      teacherName: json['teacherName'],
      classCode: json['classCode'],
      courseName: json['courseName'],
    );
  }
}
