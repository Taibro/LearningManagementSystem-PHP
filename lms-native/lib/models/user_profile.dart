class UserProfile {
  final int? id;
  final String? fullName;
  final String? email;
  final String? specificCode;
  final String? role;
  final String? token;
  final int? schoolId;

  UserProfile({
    this.id,
    this.fullName,
    this.email,
    this.specificCode,
    this.role,
    this.token,
    this.schoolId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      specificCode: json['specificCode'],
      role: json['role'],
      token: json['token'],
      schoolId: json['schoolId'],
    );
  }
}
