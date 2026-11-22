/// One month's money flow, split into operating (income/expense), debt and
/// investment movements, with the derived totals the report and AI advice read.
class CashFlowEntity {
  final int income;
  final int expense;
  final int debtInflow;
  final int debtOutflow;
  final int investmentInflow;
  final int investmentOutflow;

  const CashFlowEntity({
    required this.income,
    required this.expense,
    this.debtInflow = 0,
    this.debtOutflow = 0,
    this.investmentInflow = 0,
    this.investmentOutflow = 0,
  });

  static const double debtDominanceThreshold = 0.5;

  int get totalInflow => income + debtInflow + investmentInflow;

  int get totalOutflow => expense + debtOutflow + investmentOutflow;

  int get net => totalInflow - totalOutflow;

  int get operatingNet => income - expense;

  bool get isDeficit => operatingNet < 0;

  int get debtInflowPercent =>
      totalInflow == 0 ? 0 : (debtInflow * 100 / totalInflow).round();

  int get debtOutflowPercent =>
      totalOutflow == 0 ? 0 : (debtOutflow * 100 / totalOutflow).round();

  bool get isInflowDebtDriven =>
      debtInflow > 0 && debtInflow >= totalInflow * debtDominanceThreshold;

  bool get isOutflowDebtDriven =>
      debtOutflow > 0 && debtOutflow >= totalOutflow * debtDominanceThreshold;
}
