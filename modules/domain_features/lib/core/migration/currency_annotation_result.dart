/// Outcome of [FinancialSchemaMigration.runMigrationIfNeeded]: how many records
/// of each kind were annotated with a currency code, and whether the run succeeded.
class CurrencyAnnotationResult {
  const CurrencyAnnotationResult({
    required this.walletsUpdated,
    required this.transactionsUpdated,
    required this.budgetsUpdated,
    required this.liabilitiesUpdated,
    required this.reconciliationsUpdated,
    required this.success,
    this.errorMessage,
  });

  final int walletsUpdated;
  final int transactionsUpdated;
  final int budgetsUpdated;
  final int liabilitiesUpdated;
  final int reconciliationsUpdated;
  final bool success;
  final String? errorMessage;
}
