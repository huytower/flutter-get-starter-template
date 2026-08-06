import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/guideline_controller.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import 'transaction_form_controller.dart';

@injectable
class ExpenseFormController extends TransactionFormController {
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  final RxInt categoryKey = 0.obs;

  @override
  bool get canSubmit =>
      selectedCategory.value != null &&
      selectedWalletId.value != null &&
      amountStr.value != '0' &&
      amountStr.value.isNotEmpty;

  @override
  void onReset() {
    selectedCategory.value = null;
    categoryKey.value++;
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final params = CreateTransactionParams(
      type: TransactionType.expense,
      amount: int.tryParse(amountStr.value) ?? 0,
      categoryId: selectedCategory.value?.id ?? '',
      categoryLabel: selectedCategory.value != null
          ? el.tr(selectedCategory.value!.nameKey)
          : '',
      categoryIconCode: selectedCategory.value?.iconCode,
      categoryIconFamily: selectedCategory.value?.iconFamily,
      walletId: selectedWalletId.value ?? '',
      note: composeNote(),
      date: date.value,
    );

    final result = await getIt<CreateTransactionUseCase>().call(params);
    isSubmitting.value = false;

    result.when(
      (_) {
        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_expense_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );
        resetForm();
        refreshParent();
        // Guideline: first_transaction completed
        Get.find<GuidelineController>().completeTask('first_transaction');
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
