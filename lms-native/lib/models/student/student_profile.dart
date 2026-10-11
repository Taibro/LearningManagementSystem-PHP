class StudentProfile {
  final String? studentCode;
  final String? className;
  final String? major;
  final int? enrollmentYear;
  final String? departmentName;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? email;
  final String? phone;
  final String? address;
  final String? citizenIdNumber;
  final String? avatarUrl;

  StudentProfile({
    this.studentCode,
    this.className,
    this.major,
    this.enrollmentYear,
    this.departmentName,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.email,
    this.phone,
    this.address,
    this.citizenIdNumber,
    this.avatarUrl,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentCode: json['studentCode'],
      className: json['className'],
      major: json['major'],
      enrollmentYear: json['enrollmentYear'],
      departmentName: json['departmentName'],
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      citizenIdNumber: json['citizenIdNumber'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
