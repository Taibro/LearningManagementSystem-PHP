class Semester {
  final int? id;
  final int? academicYearId;
  final String? academicYearName;
  final String? name;
  final String? startDate;
  final String? endDate;
  final bool? isActive;

  Semester({
    this.id,
    this.academicYearId,
    this.academicYearName,
    this.name,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      academicYearId: json['academicYearId'],
      academicYearName: json['academicYearName'],
      name: json['name'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academicYearId': academicYearId,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }
}
