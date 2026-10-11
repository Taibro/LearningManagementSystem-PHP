class TeacherProfile {
  final int? teacherId;
  final String? fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? teacherCode;
  final String? degree;
  final String? specialization;
  final String? departmentName;
  final String? citizenIdNumber;
  final String? address;
  final String? primaryTeachingCourse;

  TeacherProfile({
    this.teacherId,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.email,
    this.phone,
    this.avatarUrl,
    this.teacherCode,
    this.degree,
    this.specialization,
    this.departmentName,
    this.citizenIdNumber,
    this.address,
    this.primaryTeachingCourse,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      teacherId: json['id'],
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
      teacherCode: json['teacherCode'],
      degree: json['degree'],
      specialization: json['specialization'],
      departmentName: json['departmentName'],
      citizenIdNumber: json['citizenIdNumber'],
      address: json['address'],
      primaryTeachingCourse: json['primaryTeachingCourse'],
    );
  }
}
