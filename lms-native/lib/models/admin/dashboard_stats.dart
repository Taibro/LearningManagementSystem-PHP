class DashboardStats {
  final int? totalStudents;
  final int? totalTeachers;
  final int? totalClasses;
  final int? todayAbsences;
  final double? totalTuitionDebt;
  final String? schoolName;
  final int? schoolId;

  DashboardStats({
    this.totalStudents,
    this.totalTeachers,
    this.totalClasses,
    this.todayAbsences,
    this.totalTuitionDebt,
    this.schoolName,
    this.schoolId,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStudents: json['totalStudents'],
      totalTeachers: json['totalTeachers'],
      totalClasses: json['totalClasses'],
      todayAbsences: json['todayAbsences'],
      totalTuitionDebt: json['totalTuitionDebt'] != null ? (json['totalTuitionDebt'] as num).toDouble() : null,
      schoolName: json['schoolName'],
      schoolId: json['schoolId'],
    );
  }
}
