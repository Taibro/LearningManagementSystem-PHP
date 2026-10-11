class AcademicYear {
  final int? id;
  final int? schoolId;
  final String? name;
  final String? startDate;
  final String? endDate;
  final bool? isActive;

  AcademicYear({
    this.id,
    this.schoolId,
    this.name,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id'],
      schoolId: json['schoolId'],
      name: json['name'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolId': schoolId,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}
