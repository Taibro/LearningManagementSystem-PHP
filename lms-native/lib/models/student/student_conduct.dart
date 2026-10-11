class StudentConduct {
  final String? semesterName;
  final double? gpa;
  final int? creditsEarned;
  final int? conductScore;
  final String? conductGrade;
  final String? scholarshipName;
  final double? scholarshipAmount;
  final String? notes;

  StudentConduct({
    this.semesterName,
    this.gpa,
    this.creditsEarned,
    this.conductScore,
    this.conductGrade,
    this.scholarshipName,
    this.scholarshipAmount,
    this.notes,
  });

  factory StudentConduct.fromJson(Map<String, dynamic> json) {
    return StudentConduct(
      semesterName: json['semesterName'],
      gpa: json['gpa']?.toDouble(),
      creditsEarned: json['creditsEarned'],
      conductScore: json['conductScore'],
      conductGrade: json['conductGrade'],
      scholarshipName: json['scholarshipName'],
      scholarshipAmount: json['scholarshipAmount']?.toDouble(),
      notes: json['notes'],
    );
  }
}
