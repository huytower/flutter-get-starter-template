import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/helper/budget_name_helper.dart';
import '../../../liability/presentation/get_x/liability_form_controller.dart';
import '../../../liability/presentation/get_x/lend_form_controller.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/usecases/update_transaction_usecase.dart';
import '../../../transaction/presentation/get_x/investment_form_controller.dart';

@injectable
class QuickEditTransactionSheetController extends CcGetController {
  late final TransactionEntity transaction;
  late final VoidCallback _onCloseSheet;

  final RxString amountStr = '0'.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<CategoryEntity> selectedCategory = Rxn<CategoryEntity>();
  final TextEditingController noteController = TextEditingController();

  InvestmentFormController? investmentController;
  LiabilityFormController? liabilityController;
  LendFormController? lendController;

  bool get isInvestment => transaction.isInvestmentActivity;
  bool get isDebt => transaction.isDebtActivity;
  bool get isLend =>
      transaction.type == TransactionType.debtLend ||
      transaction.type == TransactionType.debtCollect;
  bool get isBorrow =>
      transaction.type == TransactionType.debtBorrow ||
      transaction.type == TransactionType.debtRepay;

  Color accentColor(BuildContext context) {
    if (isInvestment) return PrjColors.investment;
    if (isDebt) return PrjColors.liability;
    return context.ccColorScheme.primary;
  }

  String? get categoryType {
    switch (transaction.type) {
      case TransactionType.expense:
        return CategoryType.expense;
      case TransactionType.income:
        return CategoryType.income;
      case TransactionType.debtBorrow:
      case TransactionType.debtLend:
      case TransactionType.debtRepay:
      case TransactionType.debtCollect:
        return CategoryType.liability;
      case TransactionType.investmentOut:
      case TransactionType.investmentIn:
      case TransactionType.investmentReturn:
        return CategoryType.investment;
      default:
        return CategoryType.expense;
    }
  }

  void init(TransactionEntity tx, VoidCallback onCloseSheet) {
    transaction = tx;
    _onCloseSheet = onCloseSheet;
    amountStr.value = tx.amount.toString();
    noteController.text = tx.note ?? '';

    final tag = 'quick_edit_${tx.id}';
    if (isInvestment) {
      investmentController = Get.put(
        getIt<InvestmentFormController>(),
        tag: tag,
      );
      if (tx.investmentWalletId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (investmentController != null) {
            investmentController!.selectedInvestmentWalletId.value =
                tx.investmentWalletId;
          }
        });
      }
    } else if (isBorrow) {
      liabilityController = Get.put(
        getIt<LiabilityFormController>(),
        tag: tag,
      );
      if (tx.liabilityId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (liabilityController != null) {
            liabilityController!.selectedLiabilityId.value = tx.liabilityId;
          }
        });
      }
    } else if (isLend) {
      lendController = Get.put(
        getIt<LendFormController>(),
        tag: tag,
      );
      if (tx.liabilityId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (lendController != null) {
            lendController!.selectedLiabilityId.value = tx.liabilityId;
          }
        });
      }
    }
  }

  void onQuickAmountSelected(int amount) {
    amountStr.value = amount.toString();
  }

  void onClearAmount() {
    amountStr.value = '0';
  }

  void setCategory(CategoryEntity cat) {
    selectedCategory.value = cat;
  }

  Future<void> save(BuildContext context) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      final updateUseCase = getIt<UpdateTransactionUseCase>();
      final newAmount = int.tryParse(amountStr.value) ?? 0;
      final noteText = noteController.text.trim();

      final String categoryId;
      final String categoryLabel;
      final int? categoryIconCode;
      final String? categoryIconFamily;

      if (isInvestment && investmentController != null) {
        final selectedCat = investmentController!.selectedCategory.value;
        categoryId = selectedCat?.id ?? transaction.categoryId;
        categoryLabel = selectedCat != null
            ? el.tr(selectedCat.nameKey)
            : transaction.category;
        categoryIconCode =
            selectedCat?.iconCode ?? transaction.categoryIconCode;
        categoryIconFamily =
            selectedCat?.iconFamily ?? transaction.categoryIconFamily;
      } else if (isBorrow && liabilityController != null) {
        final selectedLiabilityId =
            liabilityController!.selectedLiabilityId.value;
        final balance = liabilityController!.mergedItems.firstWhereOrNull(
          (b) => b.liability.id == selectedLiabilityId,
        );
        categoryId =
            balance?.liability.categoryId ?? transaction.categoryId;
        categoryLabel = balance != null
            ? BudgetNameHelper.getDisplayName(
                name: balance.liability.categoryLabel,
                categoryNameKey: balance.liability.categoryNameKey,
              )
            : transaction.category;
        categoryIconCode =
            balance?.liability.categoryIconCode ??
            transaction.categoryIconCode;
        categoryIconFamily =
            balance?.liability.categoryIconFamily ??
            transaction.categoryIconFamily;
      } else if (isLend && lendController != null) {
        final selectedLiabilityId = lendController!.selectedLiabilityId.value;
        final balance = lendController!.mergedItems.firstWhereOrNull(
          (b) => b.liability.id == selectedLiabilityId,
        );
        categoryId =
            balance?.liability.categoryId ?? transaction.categoryId;
        categoryLabel = balance != null
            ? BudgetNameHelper.getDisplayName(
                name: balance.liability.categoryLabel,
                categoryNameKey: balance.liability.categoryNameKey,
              )
            : transaction.category;
        categoryIconCode =
            balance?.liability.categoryIconCode ??
            transaction.categoryIconCode;
        categoryIconFamily =
            balance?.liability.categoryIconFamily ??
            transaction.categoryIconFamily;
      } else {
        final cat = selectedCategory.value;
        categoryId = cat?.id ?? transaction.categoryId;
        categoryLabel = cat != null
            ? el.tr(cat.nameKey)
            : transaction.category;
        categoryIconCode =
            cat?.iconCode ?? transaction.categoryIconCode;
        categoryIconFamily =
            cat?.iconFamily ?? transaction.categoryIconFamily;
      }

      final result = await updateUseCase.call(
        UpdateTransactionParams(
          original: transaction,
          amount: newAmount,
          categoryId: categoryId,
          categoryLabel: categoryLabel,
          categoryIconCode: categoryIconCode,
          categoryIconFamily: categoryIconFamily,
          walletId: transaction.walletId,
          note: noteText.isEmpty ? null : noteText,
          date: transaction.date,
        ),
      );

      if (!context.mounted) return;

      if (result.isSuccess()) {
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.common_save),
        );
        _onCloseSheet();
      } else {
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message:
              result.tryGetError()?.message ??
              el.tr(CcLocaleKeys.app_error_general),
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    noteController.dispose();
    final tag = 'quick_edit_${transaction.id}';
    if (investmentController != null) {
      Get.delete<InvestmentFormController>(tag: tag);
    }
    if (liabilityController != null) {
      Get.delete<LiabilityFormController>(tag: tag);
    }
    if (lendController != null) {
      Get.delete<LendFormController>(tag: tag);
    }
    super.onClose();
  }
}
