import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../domain/entities/liability_entity.dart';
import '../../domain/usecases/create_liability_usecase.dart';
import '../../domain/usecases/get_liability_balances_usecase.dart';
import 'lend_form_controller.dart';
import 'liability_form_controller.dart';
import 'liability_list_controller.dart';

@injectable
class AddLiabilitySheetController extends CcGetController {
  AddLiabilitySheetController(
    this._getCategories,
    this._getProfileSettings,
    this._createLoan,
    this._walletController,
    this._getLiabilityBalances,
  );

  final GetCategoriesUseCase _getCategories;
  final GetProfileSettingsUseCase _getProfileSettings;
  final CreateLiabilityUseCase _createLoan;
  final WalletController _walletController;
  final GetLiabilityBalancesUseCase _getLiabilityBalances;

  late final TextEditingController nameController;
  final RxString direction = LiabilityDirection.borrow.obs;

  final RxList<CategoryEntity> loanCategories = <CategoryEntity>[].obs;
  final Rxn<CategoryEntity> selectedLoanCategory = Rxn<CategoryEntity>();
  final RxBool isNameValid = false.obs;
  final RxBool isVip = false.obs;
  final Rxn<String> nameError = Rxn<String>();
  final RxBool isSubmitting = false.obs;

  void init() {
    nameController = TextEditingController();
    nameController.addListener(_onNameChanged);
    nameController.addListener(() {
      if (nameError.value != null) {
        nameError.value = null;
      }
    });
    _loadLoanCategories();
    _loadVipStatus();
  }

  void _onNameChanged() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
    if (nameError.value != null) {
      nameError.value = null;
    }
  }

  Future<void> _loadVipStatus() async {
    final settings = await _getProfileSettings();
    isVip.value = settings.isVip;
  }

  Future<void> _loadLoanCategories() async {
    final result = await _getCategories.call();
    result.when((categories) {
      final groupId = direction.value == LiabilityDirection.borrow
          ? CategorySeed.debtLoanBorrowGroupId
          : CategorySeed.debtLoanLendGroupId;

      final filtered = categories
          .where(
            (c) =>
                c.type == CategoryType.debtLoan &&
                c.isEnabled &&
                c.groupId == groupId,
          )
          .toList();

      final seedIndexMap = <String, int>{};
      for (int i = 0; i < CategorySeed.categories.length; i++) {
        seedIndexMap[CategorySeed.categories[i].id] = i;
      }

      filtered.sort((a, b) {
        final isOtherA = a.nameKey.contains('other');
        final isOtherB = b.nameKey.contains('other');
        if (isOtherA && !isOtherB) return 1;
        if (!isOtherA && isOtherB) return -1;
        final indexA = seedIndexMap[a.id] ?? 999;
        final indexB = seedIndexMap[b.id] ?? 999;
        return indexA.compareTo(indexB);
      });

      loanCategories.assignAll(filtered);
    }, (_) {});
  }

  void setDirection(String value) {
    if (direction.value == value) return;
    direction.value = value;
    selectedLoanCategory.value = null;
    _loadLoanCategories();
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
    const amount = 0;

    // Use default wallet (first liquid wallet) for simplified flow
    final wallet = _walletController.liquidWallets.firstOrNull;
    if (wallet == null) {
      isSubmitting.value = false;
      return;
    }

    final existingResult = await _getLiabilityBalances();
    if (existingResult.isSuccess()) {
      final isDuplicate = existingResult.tryGetSuccess()!.any(
        (b) =>
            b.liability.categoryLabel.trim().toLowerCase() ==
            name.toLowerCase(),
      );
      if (isDuplicate) {
        nameError.value = el.tr(
          CcLocaleKeys.transaction_liability_name_duplicate_error,
        );
        isSubmitting.value = false;
        return;
      }
    }

    final params = CreateLiabilityParams(
      direction: direction.value,
      principalAmount: amount,
      categoryId: category.id,
      categoryLabel: name,
      categoryIconCode: category.iconCode,
      categoryIconFamily: category.iconFamily,
      walletId: wallet.id,
      repaymentMethod: LiabilityRepaymentMethod.lumpSum,
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
          debugPrint(
            '[ADD_LIABILITY_SHEET] Save success, triggering refreshes',
          );
          nameError.value = null;

          // Refresh related lists immediately
          if (Get.isRegistered<BudgetAllocationController>()) {
            Get.find<BudgetAllocationController>().loadAll();
          }
          if (Get.isRegistered<LiabilityListController>()) {
            Get.find<LiabilityListController>().load();
          }
          if (Get.isRegistered<LiabilityFormController>()) {
            Get.find<LiabilityFormController>().loadLiabilities();
          }
          if (Get.isRegistered<LendFormController>()) {
            Get.find<LendFormController>().loadLiabilities();
          }

          Navigator.pop(context);
          CcSnackBarHelper.showSuccessSnackBar(
            context: context,
            message: el.tr(CcLocaleKeys.common_done),
          );

          // Guideline: update status so the badge moves to the Transaction tab
          if (Get.isRegistered<GuidelineController>()) {
            Get.find<GuidelineController>().setLiabilityCreated();
          }
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
