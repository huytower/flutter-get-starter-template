import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/repositories/liability_repository.dart';
import '../../domain/usecases/get_liability_balances_usecase.dart';

@injectable
class LiabilityListController extends CcGetController {
  LiabilityListController(
    this._getLiabilityBalances,
    this._LiabilityRepository,
  );

  final GetLiabilityBalancesUseCase _getLiabilityBalances;
  final LiabilityRepository _LiabilityRepository;

  final RxList<LiabilityBalanceEntity> loans = <LiabilityBalanceEntity>[].obs;

  final RxBool isEditMode = false.obs;
  final RxBool isVip = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    layoutStatus.value = CcLayoutStatus.loading;
    final result = await _getLiabilityBalances();
    result.when(
      (balances) {
        final unique = <String, LiabilityBalanceEntity>{};
        for (final b in balances) {
          final name = b.liability.categoryLabel.trim().toLowerCase();
          unique[name] = b;
        }
        final sorted = unique.values.toList()
          ..sort(
            (a, b) => b.liability.updatedAt.compareTo(a.liability.updatedAt),
          );
        loans.assignAll(sorted);
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
    final item = loans.removeAt(oldIndex);
    loans.insert(newIndex, item);
  }

  Future<void> deleteLiability(String id) async {
    final index = loans.indexWhere((b) => b.liability.id == id);
    if (index == -1) return;

    final result = await _LiabilityRepository.deleteLoan(id);
    result.when(
      (_) {
        loans.removeAt(index);

        GetIt.instance<BudgetAllocationController>().loadLiabilities();

        CcSnackBarHelper.showSuccessSnackBar(
          context: Get.context!,
          message: el.tr(CcLocaleKeys.common_done),
        );
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: Get.context!,
        message: el.tr(error.message),
      ),
    );
  }
}
