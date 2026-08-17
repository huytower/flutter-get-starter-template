import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';

/// budget allocation page. For full loan creation with installments, use
/// [LoanFormController] via the transaction flow.

import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/usecases/create_loan_usecase.dart';

@injectable
class AddLoanSheetController extends CcGetController {
  AddLoanSheetController(
    this._getCategories,
    this._getProfileSettings,
    this._createLoan,
  );

  final GetCategoriesUseCase _getCategories;
  final GetProfileSettingsUseCase _getProfileSettings;
  final CreateLoanUseCase _createLoan;

  late final TextEditingController counterpartyController;
  final RxString direction = LoanDirection.borrow.obs;

  final RxList<CategoryEntity> loanCategories = <CategoryEntity>[].obs;
  final Rxn<CategoryEntity> selectedLoanCategory = Rxn<CategoryEntity>();
  final RxBool isCounterpartyValid = false.obs;
  final RxBool isVip = false.obs;
  final RxBool isSubmitting = false.obs;

  void init() {
    counterpartyController = TextEditingController();
    counterpartyController.addListener(_onCounterpartyChanged);
    _onCounterpartyChanged();

    _loadLoanCategories();
    _loadVipStatus();
  }

  Future<void> _loadVipStatus() async {
    final settings = await _getProfileSettings();
    isVip.value = settings.isVip || CcFeatureFlags.isForceFullAccessEnabled;
  }

  Future<void> _loadLoanCategories() async {
    final result = await _getCategories.call();
    result.when((categories) {
      final enabledLoan = categories
          .where((c) => c.type == CategoryType.debtLoan && c.isEnabled)
          .toList();

      // Create index map to preserve seed order
      final seedIndexMap = <String, int>{};
      for (int i = 0; i < CategorySeed.categories.length; i++) {
        seedIndexMap[CategorySeed.categories[i].id] = i;
      }

      enabledLoan.sort((a, b) {
        final isOtherA = a.nameKey.contains('other');
        final isOtherB = b.nameKey.contains('other');
        if (isOtherA && !isOtherB) return 1;
        if (!isOtherA && isOtherB) return -1;
        final indexA = seedIndexMap[a.id] ?? 999;
        final indexB = seedIndexMap[b.id] ?? 999;
        return indexA.compareTo(indexB);
      });

      loanCategories.assignAll(enabledLoan);
    }, (_) {});
  }

  void _onCounterpartyChanged() {
    isCounterpartyValid.value = counterpartyController.text.trim().isNotEmpty;
  }

  void setDirection(String value) {
    if (direction.value == value) return;
    direction.value = value;
    selectedLoanCategory.value = null;
  }

  void selectLoanCategory(CategoryEntity category) {
    selectedLoanCategory.value = category;
    counterpartyController.text = el.tr(category.nameKey);
    _onCounterpartyChanged();
  }

  Future<void> save(BuildContext context) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    final category = selectedLoanCategory.value;
    if (category == null) {
      isSubmitting.value = false;
      return;
    }

    final counterpartyName = counterpartyController.text.trim();
    if (counterpartyName.isEmpty) {
      isSubmitting.value = false;
      return;
    }

    // Use default wallet (first liquid wallet) for simplified flow
    // In a real app, you'd want wallet selection
    final params = CreateLoanParams(
      direction: direction.value,
      counterpartyName: counterpartyName,
      principalAmount: 0,
      categoryId: category.id,
      categoryLabel: el.tr(category.nameKey),
      categoryIconCode: category.iconCode,
      categoryIconFamily: category.iconFamily,
      walletId: '', // TODO(user): Get default wallet ID
      repaymentMethod: LoanRepaymentMethod.lumpSum,
      installments: null,
      finalDueDate: DateTime.now().add(const Duration(days: 30)),
      note: '',
      date: DateTime.now(),
      reminderBeforeDueDate: false,
    );

    final result = await _createLoan(params);
    isSubmitting.value = false;

    result.when(
      (loan) {
        if (context.mounted) {
          Navigator.pop(context);
          CcSnackBarHelper.showSuccessSnackBar(
            context: context,
            message: el.tr(CcLocaleKeys.transaction_debt_saved),
          );
        }
      },
      (error) {
        if (context.mounted) {
          CcSnackBarHelper.showErrorSnackBar(
            context: context,
            message: el.tr(error.message),
          );
        }
      },
    );
  }

  @override
  void onClose() {
    counterpartyController.dispose();
    super.onClose();
  }
}
