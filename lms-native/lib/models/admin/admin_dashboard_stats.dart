class AdminDashboardStats {
  final int? totalStudents;
  final int? totalTeachers;
  final int? totalClasses;
  final int? todayAbsences;
  final double? totalTuitionDebt;
  final String? schoolName;

  AdminDashboardStats({
    this.totalStudents,
    this.totalTeachers,
    this.totalClasses,
    this.todayAbsences,
    this.totalTuitionDebt,
    this.schoolName,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalStudents: json['totalStudents'],
      totalTeachers: json['totalTeachers'],
      totalClasses: json['totalClasses'],
      todayAbsences: json['todayAbsences'],
      totalTuitionDebt: (json['totalTuitionDebt'] as num?)?.toDouble(),
      schoolName: json['schoolName'],
    );
  }
}
