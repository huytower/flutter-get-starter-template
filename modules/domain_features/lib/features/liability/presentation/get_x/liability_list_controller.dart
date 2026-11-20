import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/usecases/delete_liability_usecase.dart';
import '../../domain/usecases/get_liability_balances_usecase.dart';
import 'liability_form_controller.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';

@lazySingleton
class LiabilityListController extends CcGetController {
  LiabilityListController(this._getLiabilityBalances, this._deleteLiability);

  final GetLiabilityBalancesUseCase _getLiabilityBalances;
  final DeleteLiabilityUseCase _deleteLiability;

  final RxList<LiabilityBalanceEntity> liabilities =
      <LiabilityBalanceEntity>[].obs;

  List<LiabilityBalanceEntity> get borrowBalances =>
      liabilities.where((b) => b.liability.isBorrow).toList();

  List<LiabilityBalanceEntity> get lendBalances =>
      liabilities.where((b) => b.liability.isLend).toList();

  final RxBool isEditMode = false.obs;
  final RxBool isVip = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    ever(CurrencyConstants.onCurrencyChanged, (_) => load());
  }

  Future<void> load() async {
    layoutStatus.value = CcLayoutStatus.loading;
    final result = await _getLiabilityBalances();
    result.when(
      (balances) async {
        final walletController = Get.isRegistered<WalletController>()
            ? Get.find<WalletController>()
            : Get.put(getIt<WalletController>());
        final targetCurrency = walletController.currencyCode.value;

        final entries = await Future.wait(
          balances.map((b) async {
            final convPrincipal = await walletController.conversionService
                .convertAmount(
                  amount: b.liability.principalAmount,
                  fromCurrency: b.liability.currencyCode,
                  toCurrency: targetCurrency,
                );
            final convertedPrincipal =
                convPrincipal.tryGetSuccess() ?? b.liability.principalAmount;

            final convOutstanding = await walletController.conversionService
                .convertAmount(
                  amount: b.outstandingBalance,
                  fromCurrency: b.liability.currencyCode,
                  toCurrency: targetCurrency,
                );
            final convertedOutstanding =
                convOutstanding.tryGetSuccess() ?? b.outstandingBalance;

            final updatedLiability = b.liability.copyWith(
              principalAmount: convertedPrincipal,
              currencyCode: targetCurrency,
            );

            return MapEntry(
              b.liability.id,
              LiabilityBalanceEntity(
                liability: updatedLiability,
                outstandingBalance: convertedOutstanding,
              ),
            );
          }),
        );

        final unique = <String, LiabilityBalanceEntity>{};
        for (final entry in entries) {
          unique[entry.key] = entry.value;
        }

        final sorted = unique.values.toList()
          ..sort(
            (a, b) => b.liability.updatedAt.compareTo(a.liability.updatedAt),
          );
        liabilities.assignAll(sorted);
        layoutStatus.value = CcLayoutStatus.success;
      },
      (_) {
        layoutStatus.value = CcLayoutStatus.error;
      },
    );
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  void onCloseEditMode(BuildContext context) {
    if (isEditMode.value) {
      isEditMode.value = false;
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> reorderLiabilities(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = liabilities.removeAt(oldIndex);
    liabilities.insert(newIndex, item);
  }

  Future<void> deleteLiability(BuildContext context, String id) async {
    final index = liabilities.indexWhere((b) => b.liability.id == id);
    if (index == -1) return;

    final result = await _deleteLiability(liabilities[index].liability);
    result.when(
      (_) {
        liabilities.removeAt(index);

        // The deleted debt transactions change wallet balances and every
        // liability total, so refresh the dashboard (wallets included) too.
        final refresh = getIt<FinancialRefreshProvider>();
        if (Get.isRegistered<BudgetAllocationController>()) {
          refresh.refreshBudgetAllocation(showLoading: false);
        } else {
          refresh.refreshWallets(showLoading: false);
        }

        // Refresh LiabilityForm if it's open
        if (Get.isRegistered<LiabilityFormController>()) {
          Get.find<LiabilityFormController>().loadLiabilities();
        }

        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.common_done),
        );
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
