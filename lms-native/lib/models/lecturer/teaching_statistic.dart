class MonthlyChartData {
  final String? month;
  final int? periods;

  MonthlyChartData({this.month, this.periods});

  factory MonthlyChartData.fromJson(Map<String, dynamic> json) {
    return MonthlyChartData(
      month: json['month'],
      periods: json['periods'],
    );
  }
}

class ClassTeachingDetail {
  final String? subjectName;
  final String? classCode;
  final int? completedPeriods;
  final int? totalPeriods;
  final int? progressPercentage;

  ClassTeachingDetail({
    this.subjectName,
    this.classCode,
    this.completedPeriods,
    this.totalPeriods,
    this.progressPercentage,
  });

  factory ClassTeachingDetail.fromJson(Map<String, dynamic> json) {
    return ClassTeachingDetail(
      subjectName: json['subjectName'],
      classCode: json['classCode'],
      completedPeriods: json['completedPeriods'],
      totalPeriods: json['totalPeriods'],
      progressPercentage: json['progressPercentage'],
    );
  }
}

class TeachingStatistic {
  final String? currentSemesterLabel;
  final int? totalPeriods;
  final int? theoryPeriods;
  final int? theoryPercentage;
  final int? labPeriods;
  final int? labPercentage;
  final int? examShifts;
  final int? upcomingExamShifts;
  final List<MonthlyChartData>? chartData;
  final int? overallProgress;
  final List<String>? reminders;
  final List<ClassTeachingDetail>? classDetails;

  TeachingStatistic({
    this.currentSemesterLabel,
    this.totalPeriods,
    this.theoryPeriods,
    this.theoryPercentage,
    this.labPeriods,
    this.labPercentage,
    this.examShifts,
    this.upcomingExamShifts,
    this.chartData,
    this.overallProgress,
    this.reminders,
    this.classDetails,
  });

  factory TeachingStatistic.fromJson(Map<String, dynamic> json) {
    return TeachingStatistic(
      currentSemesterLabel: json['currentSemesterLabel'],
      totalPeriods: json['totalPeriods'],
      theoryPeriods: json['theoryPeriods'],
      theoryPercentage: json['theoryPercentage'],
      labPeriods: json['labPeriods'],
      labPercentage: json['labPercentage'],
      examShifts: json['examShifts'],
      upcomingExamShifts: json['upcomingExamShifts'],
      chartData: json['chartData'] != null
          ? (json['chartData'] as List)
              .map((e) => MonthlyChartData.fromJson(e))
              .toList()
          : null,
      overallProgress: json['overallProgress'],
      reminders: json['reminders'] != null
          ? List<String>.from(json['reminders'])
          : null,
      classDetails: json['classDetails'] != null
          ? (json['classDetails'] as List)
              .map((e) => ClassTeachingDetail.fromJson(e))
              .toList()
          : null,
    );
  }
}
