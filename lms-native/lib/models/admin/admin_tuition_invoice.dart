class AdminTuitionInvoice {
  final int? id;
  final int? studentId;
  final String? studentCode;
  final String? studentName;
  final double? totalAmount;
  final double? paidAmount;
  final String? status;

  AdminTuitionInvoice({
    this.id,
    this.studentId,
    this.studentCode,
    this.studentName,
    this.totalAmount,
    this.paidAmount,
    this.status,
  });

  factory AdminTuitionInvoice.fromJson(Map<String, dynamic> json) {
    return AdminTuitionInvoice(
      id: json['id'],
      studentId: json['studentId'],
      studentCode: json['studentCode'],
      studentName: json['studentName'],
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble(),
      status: json['status'],
    );
  }
}
