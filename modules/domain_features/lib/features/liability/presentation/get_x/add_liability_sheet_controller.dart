import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/di/di.dart';
import 'package:domain_features/core/domain/entities/liability_entity.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:domain_features/features/firestore/guest_login_prompt_service.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';

import '../../../../core/get_x/prj_get_controller.dart';
import '../../../../core/presentation/helper/name_suggestions.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../domain/usecases/create_liability_usecase.dart';
import '../../domain/usecases/get_liability_balances_usecase.dart';
import '../helper/liability_name_suggestions.dart';
import 'borrow_form_controller.dart';
import 'lend_form_controller.dart';
import 'liability_list_controller.dart';

@injectable
class AddLiabilitySheetController extends PrjGetController {
  AddLiabilitySheetController(
    this._getCategories,
    this._getProfileSettings,
    this._createLiability,
    this._walletController,
    this._getLiabilityBalances,
    this._refresh,
    this._guidelineProvider,
  );

  final FinancialRefreshProvider _refresh;
  final GuidelineProvider _guidelineProvider;

  final GetCategoriesUseCase _getCategories;
  final GetProfileSettingsUseCase _getProfileSettings;
  final CreateLiabilityUseCase _createLiability;
  final WalletController _walletController;
  final GetLiabilityBalancesUseCase _getLiabilityBalances;

  final TextEditingController nameController = TextEditingController();
  final RxString direction = LiabilityDirection.borrow.obs;

  final RxList<CategoryEntity> liabilityCategories = <CategoryEntity>[].obs;
  final Rxn<CategoryEntity> selectedLiabilityCategory = Rxn<CategoryEntity>();
  final RxBool hasNameValid = false.obs;
  final RxBool hasVip = false.obs;
  final Rxn<String> nameError = Rxn<String>();
  final RxBool hasSubmitting = false.obs;

  final RxBool showDirectionToggle = false.obs;

  void prepareForm({
    String initialDirection = LiabilityDirection.borrow,
    bool showDirectionToggle = false,
  }) {
    this.showDirectionToggle.value = showDirectionToggle;
    direction.value = initialDirection;
    selectedLiabilityCategory.value = null;
    nameController.text = '';
    nameController.removeListener(_onNameChanged);
    nameController.addListener(_onNameChanged);
    nameController.addListener(() {
      if (nameError.value != null) {
        nameError.value = null;
      }
    });
    _loadLiabilityCategories();
    _loadVipStatus();
  }

  void _onNameChanged() {
    hasNameValid.value = nameController.text.trim().isNotEmpty;
    if (nameError.value != null) {
      nameError.value = null;
    }
  }

  Future<void> _loadVipStatus() async {
    final settings = await _getProfileSettings();
    hasVip.value = settings.hasVipAccess;
  }

  Future<void> _loadLiabilityCategories() async {
    final result = await _getCategories.call();
    result.when((categories) {
      final groupId = direction.value == LiabilityDirection.borrow
          ? CategorySeed.liabilityBorrowGroupId
          : CategorySeed.debtLoanLendGroupId;

      final filtered = categories
          .where(
            (c) =>
                c.type == CategoryType.liability &&
                c.hasEnabled &&
                c.groupId == groupId,
          )
          .toList();

      final seedIndexMap = <String, int>{};
      for (int i = 0; i < CategorySeed.categories.length; i++) {
        seedIndexMap[CategorySeed.categories[i].id] = i;
      }

      filtered.sort((a, b) {
        final hasOtherA = a.nameKey.contains('other');
        final hasOtherB = b.nameKey.contains('other');
        if (hasOtherA && !hasOtherB) return 1;
        if (!hasOtherA && hasOtherB) return -1;
        final indexA = seedIndexMap[a.id] ?? 999;
        final indexB = seedIndexMap[b.id] ?? 999;
        return indexA.compareTo(indexB);
      });

      liabilityCategories.assignAll(filtered);

      // Automatically pre-select the first category for the active direction
      if (filtered.isNotEmpty &&
          (selectedLiabilityCategory.value == null ||
              selectedLiabilityCategory.value!.groupId != groupId)) {
        selectLiabilityCategory(filtered.first);
      }
    }, (_) {});
  }

  void setDirection(String value) {
    if (direction.value == value) return;
    direction.value = value;
    _clearSuggestedName();
    selectedLiabilityCategory.value = null;
    _loadLiabilityCategories();
  }

  /// Selects [category] without filling the name: the field stays empty so
  /// its hint points at the category's suggestions. A name picked from the
  /// previous category's suggestions is cleared; a typed name is kept.
  void selectLiabilityCategory(CategoryEntity category) {
    _clearSuggestedName();
    selectedLiabilityCategory.value = category;
  }

  void _clearSuggestedName() => NameSuggestions.clearIfSuggested(
    nameController,
    LiabilityNameSuggestions.keyFor(selectedLiabilityCategory.value?.id),
  );

  Future<void> save(BuildContext context) async {
    if (hasSubmitting.value) return;
    hasSubmitting.value = true;

    try {
      final name = nameController.text.trim();
      final category = selectedLiabilityCategory.value;
      if (category == null) {
        return;
      }

      // Default to 0 amount
      const amount = 0;

      // Use default wallet (first liquid wallet) for simplified flow
      final wallet = _walletController.liquidWallets.firstOrNull;
      if (wallet == null) {
        return;
      }

      final existingResult = await _getLiabilityBalances();
      if (existingResult.isSuccess()) {
        final hasDuplicate = existingResult.tryGetSuccess()!.any(
          (b) =>
              b.liability.direction == direction.value &&
              b.liability.categoryLabel.trim().toLowerCase() ==
                  name.toLowerCase(),
        );
        if (hasDuplicate) {
          nameError.value = el.tr(
            PrjLocaleKeys.transaction_liability_name_duplicate_error,
          );
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

      final result = await _createLiability(params);

      result.when(
        (liability) {
          if (context.mounted) {
            nameError.value = null;

            // Refresh related lists immediately
            _refresh.refreshBudgetAllocation();
            if (Get.isRegistered<LiabilityListController>()) {
              Get.find<LiabilityListController>().load();
            }
            if (Get.isRegistered<BorrowFormController>()) {
              Get.find<BorrowFormController>().loadLiabilities();
            }
            if (Get.isRegistered<LendFormController>()) {
              Get.find<LendFormController>().loadLiabilities();
            }

            Navigator.pop(context);
            CcSnackBarHelper.showSuccessSnackBar(
              context: context,
              message: el.tr(PrjLocaleKeys.common_done),
            );

            // Guideline: update status so the badge moves to the Transaction tab
            _guidelineProvider.setLiabilityCreated();
            if (context.mounted) {
              unawaited(getIt<GuestLoginPromptService>().maybeShow(context));
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
    } finally {
      hasSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
