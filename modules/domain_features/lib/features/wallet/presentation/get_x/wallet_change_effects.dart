import 'dart:async';

import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/firestore/guest_login_prompt_service.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

/// What other features see when a wallet changes: the transaction screen's
/// wallet picker, budget allocation and reconciliation totals, the onboarding
/// guideline, and the guest sign-in prompt.
///
/// The wallet controllers call this instead of reaching other features'
/// controllers.
@injectable
class WalletChangeEffects {
  WalletChangeEffects(this._refresh, this.guideline, this._guestPrompt);

  final FinancialRefreshProvider _refresh;
  final GuestLoginPromptService _guestPrompt;

  /// The onboarding guideline, read by the wallet screens for their badges.
  final GuidelineProvider guideline;

  /// Onboarding task completed by giving a wallet a balance.
  static const String balanceTask = 'wallet_balance';

  void added(WalletEntity wallet) => _refresh.addWalletToTransactions(wallet);

  /// [saved] replaced [original]; completes the balance task when it now has
  /// a balance.
  void updated(WalletEntity saved, WalletEntity original) {
    _refresh.updateWalletInTransactions(saved);
    if (saved.balance > 0) {
      guideline.completeTask(balanceTask);
    }
    if (saved.type == WalletType.cash && saved.balance != original.balance) {
      guideline.completeTask(balanceTask);
    }
  }

  /// A wallet was deleted: drop it from the transaction picker, then re-read
  /// every screen that showed its transactions. Deleting an investment
  /// position also deletes its entries and moves money on the liquid wallets,
  /// and the screens (the Report included) outlive their pages, so they keep
  /// the old records until told to reload.
  void removed(String walletId) {
    _refresh.removeWalletFromTransactions(walletId);
    unawaited(_reloadAfterRemoval(walletId));
  }

  Future<void> _reloadAfterRemoval(String walletId) async {
    await _refresh.refreshAllLoaded();
    await _refresh.refreshReport(showLoading: false);
  }

  void deletionConfirmed() => _refresh.refreshReconciliationBalances();

  /// After the add/edit sheet saved: refresh budget allocation, complete the
  /// balance task for a first wallet, and maybe ask a guest to sign in.
  Future<void> afterSheetSaved({required bool created}) async {
    _refresh.refreshBudgetAllocation();
    if (created &&
        guideline.hasAvailable &&
        guideline.hasTaskActive(balanceTask)) {
      await guideline.completeTask(balanceTask);
    }
  }

  /// Shown once a guest has created enough data.
  void promptGuestSignIn(BuildContext context) =>
      unawaited(_guestPrompt.maybeShow(context));
}
