import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/presentation/get_x/transaction_controller.dart';
import '../../../transaction/presentation/get_x/transaction_form_controller.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';
import '../../domain/repositories/liability_repository.dart';
import '../../domain/usecases/liability_balance_calculator.dart';
import '../../domain/usecases/record_liability_payment_usecase.dart';

/// Loan detail screen state: loan info, outstanding balance, transaction
/// history, and the Trả nợ/Thu nợ (repay/collect) form for this one loan.
@injectable
class LiabilityDetailController extends TransactionFormController {
  LiabilityDetailController(
    this._LiabilityRepository,
    this._transactionRepository,
    this._recordLiabilityPayment,
  );

  final LiabilityRepository _LiabilityRepository;
  final TransactionRepository _transactionRepository;
  final RecordLiabilityPaymentUseCase _recordLiabilityPayment;

  final Rx<LiabilityEntity?> liability = Rx<LiabilityEntity?>(null);
  final RxInt outstandingBalance = 0.obs;
  final RxList<TransactionEntity> history = <TransactionEntity>[].obs;
  final RxBool isLoadingDetail = false.obs;

  String? _liabilityId;

  bool get isSettled => outstandingBalance.value <= 0;

  @override
  void onInit() {
    // TransactionFormController.onInit() -> _loadWallets() requires a
    // registered TransactionController. This page may be reached directly
    // (e.g. from the standalone loan list) without the Transaction tab ever
    // having been visited.
    if (!Get.isRegistered<TransactionController>()) {
      Get.put(getIt<TransactionController>());
    }
    super.onInit();
  }

  /// Seeds from the already-known [balance] (avoids a loading flash for the
  /// fields the caller already has), then loads fresh history + balance.
  Future<void> load(LiabilityBalanceEntity balance) async {
    liability.value = balance.liability;
    outstandingBalance.value = balance.outstandingBalance;
    if (_liabilityId == balance.liability.id) return;
    _liabilityId = balance.liability.id;
    await _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    final liabilityId = _liabilityId;
    if (liabilityId == null) return;
    isLoadingDetail.value = true;

    final liabilityResult = await _LiabilityRepository.getLiability(
      liabilityId,
    );
    final txnResult = await _transactionRepository.getTransactionsByLiability(
      liabilityId,
    );

    liabilityResult.when((l) => liability.value = l, (_) {});
    txnResult.when((txns) {
      history.assignAll(txns);
      final current = liability.value;
      if (current != null) {
        outstandingBalance.value = liabilityOutstandingBalance(
          current.principalAmount,
          txns,
        );
      }
    }, (_) {});

    isLoadingDetail.value = false;
  }

  @override
  bool get canSubmit {
    if (isSettled) return false;
    if (amountStr.value == '0' || amountStr.value.isEmpty) return false;
    if (selectedWalletId.value == null) return false;
    final amount = int.tryParse(amountStr.value) ?? 0;
    return amount > 0 && amount <= outstandingBalance.value;
  }

  @override
  void onReset() {}

  @override
  Future<void> submitForm(BuildContext context) async {
    final liabilityId = _liabilityId;
    if (isSubmitting.value || !canSubmit || liabilityId == null) return;
    isSubmitting.value = true;

    final params = RecordLiabilityPaymentParams(
      liabilityId: liabilityId,
      walletId: selectedWalletId.value ?? '',
      amount: int.tryParse(amountStr.value) ?? 0,
      note: composeNote(),
      date: date.value,
    );

    final result = await _recordLiabilityPayment(params);
    isSubmitting.value = false;

    result.when(
      (_) async {
        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_liability_payment_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );
        resetForm();
        await refreshParent();
        await _refreshDetail();
        if (Get.isRegistered<BudgetAllocationController>()) {
          Get.find<BudgetAllocationController>().loadAll();
        }
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }

  @override
  void clearCategorySelection() {
    // This form is locked to a single specific loan, so we don't clear
    // the category selection here.
  }
}
