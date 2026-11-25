/// Repayment method values stored in [LiabilityEntity.repaymentMethod].
abstract class LiabilityRepaymentMethod {
  /// Trả góp — a schedule of due-date + amount periods.
  static const String installment = 'installment';

  /// Đáo hạn / Trả 1 lần — a single final due date.
  static const String lumpSum = 'lump_sum';
}

