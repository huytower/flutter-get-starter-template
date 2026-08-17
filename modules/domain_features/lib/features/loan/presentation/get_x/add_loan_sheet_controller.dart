import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/usecases/create_loan_usecase.dart';

@injectable
class AddLoanSheetController extends CcGetController {
  AddLoanSheetController(
    this._getCategories,
    this._getProfileSettings,
    this._createLoan,
    this._walletController,
  );

  final GetCategoriesUseCase _getCategories;
  final GetProfileSettingsUseCase _getProfileSettings;
  final CreateLoanUseCase _createLoan;
  final WalletController _walletController;

  late final TextEditingController nameController;
  final RxString direction = LoanDirection.borrow.obs;

  final RxList<CategoryEntity> loanCategories = <CategoryEntity>[].obs;
  final Rxn<CategoryEntity> selectedLoanCategory = Rxn<CategoryEntity>();
  final RxBool isNameValid = false.obs;
  final RxBool isVip = false.obs;
  final RxBool isSubmitting = false.obs;

  void init() {
    nameController = TextEditingController();
    nameController.addListener(_onNameChanged);
    _loadLoanCategories();
    _loadVipStatus();
  }

  void _onNameChanged() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
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

  void setDirection(String value) {
    if (direction.value == value) return;
    direction.value = value;
    selectedLoanCategory.value = null;
  }

  void selectLoanCategory(CategoryEntity category) {
    selectedLoanCategory.value = category;
    nameController.text = el.tr(category.nameKey);
  }

  Future<void> save(BuildContext context) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    final name = nameController.text.trim();
    final category = selectedLoanCategory.value;
    if (category == null) {
      isSubmitting.value = false;
      return;
    }

    // Default to 0 amount
    final amount = 0;

    // Use default wallet (first liquid wallet) for simplified flow
    final wallet = _walletController.liquidWallets.firstOrNull;
    if (wallet == null) {
      isSubmitting.value = false;
      return;
    }

    final params = CreateLoanParams(
      direction: direction.value,
      principalAmount: amount,
      categoryId: category.id,
      categoryLabel: name,
      categoryIconCode: category.iconCode,
      categoryIconFamily: category.iconFamily,
      walletId: wallet.id,
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
    nameController.dispose();
    super.onClose();
  }
}
