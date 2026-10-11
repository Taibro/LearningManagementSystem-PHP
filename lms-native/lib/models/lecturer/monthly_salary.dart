class MonthlySalary {
  final int? periodMonth;
  final int? periodYear;
  final double? baseAmount;
  final double? sessionAmount;
  final double? bonusAmount;
  final double? deductionAmount;
  final double? netAmount;
  final double? coefficientSnapshot;

  MonthlySalary({
    this.periodMonth,
    this.periodYear,
    this.baseAmount,
    this.sessionAmount,
    this.bonusAmount,
    this.deductionAmount,
    this.netAmount,
    this.coefficientSnapshot,
  });

  factory MonthlySalary.fromJson(Map<String, dynamic> json) {
    return MonthlySalary(
      periodMonth: json['periodMonth'],
      periodYear: json['periodYear'],
      baseAmount: (json['baseAmount'] as num?)?.toDouble(),
      sessionAmount: (json['sessionAmount'] as num?)?.toDouble(),
      bonusAmount: (json['bonusAmount'] as num?)?.toDouble(),
      deductionAmount: (json['deductionAmount'] as num?)?.toDouble(),
      netAmount: (json['netAmount'] as num?)?.toDouble(),
      coefficientSnapshot: (json['coefficientSnapshot'] as num?)?.toDouble(),
    );
  }
}
