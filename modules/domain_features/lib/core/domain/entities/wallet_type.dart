/// Wallet type values stored in [WalletEntity.type].
///
/// `cash` is a singleton wallet with a fixed name/icon; `bank` and `credit`
/// are user-managed. (Legacy wallets stored as `'spending'` are migrated to
/// [bank] by the local datasource.)
abstract class WalletType {
  static const String cash = 'cash';
  static const String bank = 'bank';
  static const String ewallet = 'ewallet';
  static const String investment = 'investment';

  /// "Quỹ dự phòng" — a real, user-managed wallet like [bank]/[ewallet], but
  /// tracked in its own Budget Allocation hero banner (mirrors [investment])
  /// instead of the liquid-wallets strip. Its balance is user-entered
  /// directly (no formula), and it still counts as spendable cash for the
  /// Financial Runway calculation and as a normal wallet in Expense/Income
  /// pickers — only [investment] is excluded from those.
  static const String emergencyFund = 'emergency_fund';
}

