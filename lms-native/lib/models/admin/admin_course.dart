class AdminCourse {
  final int? id;
  final String? code;
  final String? name;
  final int? credits;
  final String? departmentName;

  AdminCourse({
    this.id,
    this.code,
    this.name,
    this.credits,
    this.departmentName,
  });

  factory AdminCourse.fromJson(Map<String, dynamic> json) {
    return AdminCourse(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      credits: json['credits'],
      departmentName: json['departmentName'],
    );
  }
}
