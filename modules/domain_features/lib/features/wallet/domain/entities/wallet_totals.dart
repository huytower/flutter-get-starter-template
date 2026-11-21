import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/wallet/domain/services/wallet_ledger.dart';

/// Header totals of the wallet screens, all in the user's display currency.
class WalletTotals {
  const WalletTotals({
    required this.total,
    required this.liquid,
    required this.emergencyFund,
    required this.allTimeInvested,
    required this.allTimeReturned,
    required this.monthlyInvested,
    required this.monthlyReturned,
    required this.roiPercent,
    required this.breakevenPercent,
    required this.monthlyRoiPercent,
    required this.monthlyBreakevenPercent,
  });

  /// Totals of [wallets] from their display balances and investment stats.
  factory WalletTotals.of(
    List<WalletEntity> wallets, {
    required int Function(String walletId) displayBalanceOf,
    required InvestmentStats Function(String walletId) statsOf,
    required InvestmentStats Function(String walletId) monthlyStatsOf,
  }) {
    int sumOf(bool Function(WalletEntity) test) =>
        wallets.where(test).fold(0, (sum, w) => sum + displayBalanceOf(w.id));

    var invested = 0, returned = 0, monthContributed = 0, monthReturned = 0;
    for (final w in wallets.where((w) => w.type == WalletType.investment)) {
      final all = statsOf(w.id);
      final month = monthlyStatsOf(w.id);
      invested += all.contributed;
      returned += all.returned;
      monthContributed += month.contributed;
      monthReturned += month.returned;
    }
    final noMonthly = monthContributed == 0 || monthReturned == 0;

    return WalletTotals(
      total: sumOf((_) => true),
      liquid: sumOf(
        (w) =>
            w.type == WalletType.cash ||
            w.type == WalletType.bank ||
            w.type == WalletType.ewallet,
      ),
      emergencyFund: sumOf((w) => w.type == WalletType.emergencyFund),
      allTimeInvested: invested,
      allTimeReturned: returned,
      monthlyInvested: monthContributed,
      monthlyReturned: monthReturned,
      roiPercent: invested == 0 ? 0 : (returned - invested) / invested * 100,
      breakevenPercent: invested == 0 ? 0 : returned / invested * 100,
      monthlyRoiPercent: noMonthly
          ? 0
          : (monthReturned - monthContributed) / monthContributed * 100,
      monthlyBreakevenPercent: noMonthly
          ? 0
          : monthReturned / monthContributed * 100,
    );
  }

  final int total;

  /// Cash, bank and e-wallets.
  final int liquid;
  final int emergencyFund;
  final int allTimeInvested;
  final int allTimeReturned;
  final int monthlyInvested;
  final int monthlyReturned;

  /// (Σ returned − Σ contributed) ÷ Σ contributed, across investment wallets.
  final double roiPercent;

  /// Σ returned ÷ Σ contributed (recovery rate).
  final double breakevenPercent;
  final double monthlyRoiPercent;
  final double monthlyBreakevenPercent;
}
