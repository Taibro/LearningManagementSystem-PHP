class TuitionPayment {
  final int id;
  final String transactionCode;
  final double amount;
  final String paymentMethod;
  final String paymentDate;
  final String status;
  final String note;

  TuitionPayment({
    required this.id,
    required this.transactionCode,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.status,
    required this.note,
  });

  factory TuitionPayment.fromJson(Map<String, dynamic> json) {
    return TuitionPayment(
      id: json['id'] ?? 0,
      transactionCode: json['transactionCode'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentDate: json['paymentDate'] ?? '',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
    );
  }
}
