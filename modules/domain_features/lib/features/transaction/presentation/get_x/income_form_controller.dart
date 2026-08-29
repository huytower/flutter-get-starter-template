import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import 'quick_entry_mixin.dart';
import 'transaction_form_controller.dart';

@injectable
class IncomeFormController extends TransactionFormController
    with QuickEntryMixin {
  @override
  String get quickEntryCategoryType => CategoryType.income;

  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  @override
  final RxInt categoryKey = 0.obs;

  /// Set right before [categoryKey] is bumped by
  /// [QuickEntryMixin.applyQuickEntryCategory], so the remounted
  /// `CategorySelectionSection` resolves and reports back the real
  /// [CategoryEntity] for this id.
  @override
  final Rx<String?> pendingPrefillCategoryId = Rx<String?>(null);

  final RxList<int> quickAmounts = RxList<int>(MoneyConstants.quickAmounts);

  @override
  void onInit() {
    super.onInit();
    _loadSuggestions();
    initQuickEntry();
  }

  @override
  void onClose() {
    disposeQuickEntry();
    super.onClose();
  }

  Future<void> _loadSuggestions() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    quickAmounts.assignAll(
      MoneyConstants.getIncomeSuggestions(settings.birthYear),
    );
  }

  @override
  bool get canSubmit =>
      selectedCategory.value != null &&
      selectedWalletId.value != null &&
      amountStr.value != '0' &&
      amountStr.value.isNotEmpty;

  @override
  void applyResolvedCategory(CategoryEntity category) {
    selectedCategory.value = category;
  }

  @override
  void onReset() {
    selectedCategory.value = null;
    categoryKey.value++;
    resetQuickEntry();
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
    // Manual selection clears any pending prefill from AI suggestions so it
    // doesn't clobber the user's choice on the next rebuild.
    pendingPrefillCategoryId.value = null;
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final categoryId = selectedCategory.value?.id ?? '';
    final categoryLabel = selectedCategory.value != null
        ? el.tr(selectedCategory.value!.nameKey)
        : '';
    final amount = int.tryParse(amountStr.value) ?? 0;

    final result = isEditing
        ? await getIt<UpdateTransactionUseCase>().call(
            UpdateTransactionParams(
              original: editingTransaction!,
              amount: amount,
              categoryId: categoryId,
              categoryLabel: categoryLabel,
              categoryIconCode: selectedCategory.value?.iconCode,
              categoryIconFamily: selectedCategory.value?.iconFamily,
              walletId: selectedWalletId.value ?? '',
              note: composeNote(),
              date: date.value,
            ),
          )
        : await getIt<CreateTransactionUseCase>().call(
            CreateTransactionParams(
              type: TransactionType.income,
              amount: amount,
              categoryId: categoryId,
              categoryLabel: categoryLabel,
              categoryIconCode: selectedCategory.value?.iconCode,
              categoryIconFamily: selectedCategory.value?.iconFamily,
              walletId: selectedWalletId.value ?? '',
              note: composeNote(),
              date: date.value,
            ),
          );
    isSubmitting.value = false;

    result.when(
      (_) async {
        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            isEditing
                ? CcLocaleKeys.transaction_income_updated
                : CcLocaleKeys.transaction_income_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );
        if (isEditing) {
          onEditSaved?.call();
        } else {
          resetForm();
        }
        await refreshParent();
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
