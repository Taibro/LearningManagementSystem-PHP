class StudentDebt {
  final int? semesterId;
  final String? semesterName;
  final String? semesterStartDate;
  final String? classCode;
  final String? courseCode;
  final String? courseName;
  final int? credits;
  final double? mucNop;
  final double? soTienNop;
  final int? isPaid;
  final String? paidDate;
  final double? invoicePaid;
  final double? invoiceTotal;

  StudentDebt({
    this.semesterId,
    this.semesterName,
    this.semesterStartDate,
    this.classCode,
    this.courseCode,
    this.courseName,
    this.credits,
    this.mucNop,
    this.soTienNop,
    this.isPaid,
    this.paidDate,
    this.invoicePaid,
    this.invoiceTotal,
  });

  factory StudentDebt.fromJson(Map<String, dynamic> json) {
    return StudentDebt(
      semesterId: json['semesterId'],
      semesterName: json['semesterName'],
      semesterStartDate: json['semesterStartDate'],
      classCode: json['classCode'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      credits: json['credits'],
      mucNop: json['mucNop']?.toDouble(),
      soTienNop: json['soTienNop']?.toDouble(),
      isPaid: json['isPaid'],
      paidDate: json['paidDate'],
      invoicePaid: json['invoicePaid']?.toDouble(),
      invoiceTotal: json['invoiceTotal']?.toDouble(),
    );
  }
}
