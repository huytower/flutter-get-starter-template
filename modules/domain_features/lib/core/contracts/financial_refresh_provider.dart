import 'package:domain_features/core/domain/entities/wallet_entity.dart';

/// Cross-feature refresh of in-memory screen state after another feature
/// changed the underlying data.
///
/// Features call this instead of importing each other's controllers; the App
/// orchestrator (`modules/bridge`) implements it. Every method is a no-op for
/// a feature whose screen controller is not currently mounted.
///
/// ```dart
/// await getIt<FinancialRefreshProvider>().refreshWallets(showLoading: false);
/// ```
abstract class FinancialRefreshProvider {
  Future<void> refreshWallets({bool showLoading = true});

  /// Transaction screen totals and wallet picker.
  Future<void> refreshTransactions();

  /// Adds a just-created wallet to the transaction screen's wallet picker.
  void addWalletToTransactions(WalletEntity wallet);

  /// Replaces [wallet] in the transaction screen's wallet picker (reloads the
  /// picker when it does not hold that wallet yet).
  void updateWalletInTransactions(WalletEntity wallet);

  /// Drops a deleted wallet from the transaction screen's wallet picker.
  void removeWalletFromTransactions(String walletId);

  Future<void> refreshBudgetAllocation({bool showLoading = true});

  Future<void> refreshBudgetLimits();

  /// The borrow-form liability list (not the lend form).
  Future<void> refreshBorrowForm();

  Future<void> refreshLiabilityList();

  Future<void> refreshReport({bool showLoading = true});

  Future<void> refreshReconciliationBalances();

  Future<void> refreshCategorySettings();

  /// Re-reads every mounted financial screen from storage, without loaders.
  Future<void> refreshAllLoaded();

  /// Blanks every mounted financial screen's in-memory records (sign-out).
  Future<void> releaseAllLoaded();
}
