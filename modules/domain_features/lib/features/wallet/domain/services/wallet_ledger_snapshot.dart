/// Capital put into an investment wallet and profit taken out of it.
typedef InvestmentStats = ({int contributed, int returned});

/// Balances derived from every transaction, per wallet id.
class WalletLedgerSnapshot {
  const WalletLedgerSnapshot({
    required this.walletsWithTransactions,
    required this.bookBalances,
    required this.investmentStats,
    required this.monthlyInvestmentStats,
  });

  /// Wallets with at least one (non-deleted) transaction.
  final Set<String> walletsWithTransactions;

  /// Opening balance ± transactions, in each wallet's own currency.
  final Map<String, int> bookBalances;

  /// All-time stats of investment wallets, in the target currency.
  final Map<String, InvestmentStats> investmentStats;

  /// Current-month stats of investment wallets, in the target currency.
  final Map<String, InvestmentStats> monthlyInvestmentStats;
}
