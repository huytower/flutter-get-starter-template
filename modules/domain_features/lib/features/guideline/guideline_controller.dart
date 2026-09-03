import 'dart:async';

import 'package:app_config/export_app_config.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../user_level/presentation/get_x/user_level_controller.dart';
import '../wallet/domain/entities/wallet_entity.dart';
import '../wallet/presentation/get_x/wallet_controller.dart';

@lazySingleton
class GuidelineController extends GetxController {
  GuidelineController(this._userLevelController);

  final UserLevelController _userLevelController;

  final List<String> taskSequence = [
    'birth_year', // Profile -> _pickBirthYear
    'categories', // Profile -> CategorySettingsPage
    'wallet_balance', // Liquid Wallet List -> Edit Cash Wallet
    'budget_limit', // Budget Allocation -> BudgetLimitListPage
    'min_living', // Budget Allocation -> AddBudgetLimitSheet (storm icon)
    'first_transaction', // Transaction -> ExpenseForm
    'investment', // Budget Allocation -> Add Investment + Transaction -> Investment tab
    'liability', // Budget Allocation -> Add Liability + Transaction -> Debt/Loan tab
    'lend', // Transaction -> Lend tab
  ];

  final Map<String, Color> taskColors = {
    'birth_year': Colors.purple,
    'categories': Colors.deepOrange,
    'wallet_balance': Colors.indigo,
    'budget_limit': Colors.cyan,
    'min_living': Colors.amber,
    'first_transaction': Colors.pink,
    'investment': Colors.green,
    'liability': Colors.deepPurple,
    'lend': Colors.teal,
  };

  final RxList<String> completedTasks = <String>[].obs;

  /// Trigger for the bounce animation on the tab bar.
  final RxInt bounceTrigger = 0.obs;

  /// Whether the descriptive text labels on guideline badges are hidden.
  /// Users can tap a bubble to hide all of them.
  final RxBool isDescriptionHidden = false.obs;

  /// Whether the large guideline banner in the page header is hidden.
  /// Users can swipe to hide it.
  final RxBool isBannerHidden = false.obs;

  /// True once the user has created their first investment position.
  /// Controls where the investment guideline badge points:
  /// - false -> Budget Allocation tab + Add Investment button
  /// - true  -> Transaction tab + Investment record
  final RxBool hasCreatedFirstInvestment = false.obs;

  /// True once the user has created their first liability (debt/loan).
  /// Controls where the liability guideline badge points:
  /// - false -> Budget Allocation tab + Add Liability button
  /// - true  -> Transaction tab + Liability record
  final RxBool hasCreatedFirstLiability = false.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = CcAppStorage.instance.completedGuidelineTaskIds;
    if (saved != null) {
      completedTasks.assignAll(saved);
    }
    _restoreTaskStatus();

    // Reset visibility states when the current step changes.
    // This ensures the description/banner is shown for the new step even if
    // the user dismissed them for the previous step.
    ever(completedTasks, (_) {
      isDescriptionHidden.value = false;
      isBannerHidden.value = false;
    });
  }

  Future<void> _restoreTaskStatus() async {
    _restoreInvestmentStatus();
    _restoreLiabilityStatus();
  }

  Future<void> _restoreInvestmentStatus() async {
    if (hasCreatedFirstInvestment.value) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('has_created_first_investment') ?? false) {
      hasCreatedFirstInvestment.value = true;
      return;
    }

    try {
      final walletController = getIt<WalletController>();
      if (walletController.wallets.any(
        (w) => w.type == WalletType.investment,
      )) {
        hasCreatedFirstInvestment.value = true;
        await prefs.setBool('has_created_first_investment', true);
      }
    } catch (_) {
      // WalletController not ready yet; will be checked on next signal.
    }
  }

  Future<void> _restoreLiabilityStatus() async {
    if (hasCreatedFirstLiability.value) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('has_created_first_liability') ?? false) {
      hasCreatedFirstLiability.value = true;
      return;
    }

    try {
      final budgetController = getIt<BudgetAllocationController>();
      if (budgetController.liabilityBalances.isNotEmpty) {
        hasCreatedFirstLiability.value = true;
        await prefs.setBool('has_created_first_liability', true);
      }
    } catch (_) {
      // Controller not ready yet
    }
  }

  bool isTaskCompleted(String taskId) => completedTasks.contains(taskId);

  String? get currentTaskId {
    final status = _userLevelController.status.value;
    for (final taskId in taskSequence) {
      if (taskId == 'investment' && !status.canUseInvestment) continue;
      if (taskId == 'liability' && !status.canUseDebtLoan) continue;
      if (taskId == 'lend' && !status.canUseDebtLoan) continue;
      if (!completedTasks.contains(taskId)) {
        return taskId;
      }
    }
    return null;
  }

  Color get currentColor {
    final activeId = currentTaskId;
    if (activeId == null) return Colors.green;
    return taskColors[activeId] ?? Colors.green;
  }

  int get currentStep => (currentTaskId != null)
      ? taskSequence.indexOf(currentTaskId!) + 1
      : taskSequence.length + 1;

  bool isTaskActive(String taskId) => currentTaskId == taskId;

  /// Returns 0: Budget Allocation, 1: Transaction, 2: Profile
  int get activeTabIndex {
    final activeId = currentTaskId;
    if (activeId == null) return -1;

    if (activeId == 'birth_year' || activeId == 'categories') {
      return 2; // Profile tab
    }
    if (activeId == 'wallet_balance' ||
        activeId == 'budget_limit' ||
        activeId == 'min_living') {
      return 0; // Budget Allocation tab
    }
    if (activeId == 'first_transaction') {
      return 1; // Transaction tab
    }
    if (activeId == 'investment') {
      return hasCreatedFirstInvestment.value ? 1 : 0;
    }
    if (activeId == 'liability') {
      return hasCreatedFirstLiability.value ? 1 : 0;
    }
    if (activeId == 'lend') {
      return 1; // Transaction tab -> Lend subtab
    }
    return -1;
  }

  void triggerBounce() {
    bounceTrigger.value++;
  }

  Future<void> completeTask(String taskId) async {
    if (!taskSequence.contains(taskId)) return;
    if (completedTasks.contains(taskId)) return;

    completedTasks.add(taskId);
    CcAppStorage.instance.completedGuidelineTaskIds = completedTasks.toList();
    await CcAppStorage.instance.save();

    unawaited(_userLevelController.refresh());
  }

  /// Call after the user successfully creates their first investment
  /// position. Moves the guideline badge from Budget Allocation to the
  /// Transaction tab so they can review their new investment record.
  Future<void> setInvestmentCreated() async {
    if (hasCreatedFirstInvestment.value) return;
    hasCreatedFirstInvestment.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_created_first_investment', true);
    triggerBounce();
  }

  /// Call after the user successfully creates their first liability record.
  /// Moves the guideline badge from Budget Allocation to the Transaction tab.
  Future<void> setLiabilityCreated() async {
    if (hasCreatedFirstLiability.value) return;
    hasCreatedFirstLiability.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_created_first_liability', true);
    triggerBounce();
  }

  /// Resets all completed guideline tasks, showing the guide banner again.
  Future<void> resetGuideline() async {
    completedTasks.clear();
    CcAppStorage.instance.completedGuidelineTaskIds = [];
    await CcAppStorage.instance.save();
    hasCreatedFirstInvestment.value = false;
    hasCreatedFirstLiability.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_created_first_investment');
    await prefs.remove('has_created_first_liability');
    triggerBounce();
  }

  String get bannerTitle {
    final remaining = taskSequence.length - completedTasks.length;
    return el.tr(
      CcLocaleKeys.guideline_banner_title_in_progress,
      namedArgs: {'remaining': remaining.toString()},
    );
  }

  String get bannerDescription {
    if (currentTaskId == null) {
      return el.tr(CcLocaleKeys.guideline_banner_desc_completed);
    }
    switch (currentTaskId) {
      case 'birth_year':
        return el.tr(CcLocaleKeys.guideline_banner_desc_birth_year);
      case 'categories':
        return el.tr(CcLocaleKeys.guideline_banner_desc_categories);
      case 'wallet_balance':
        return el.tr(CcLocaleKeys.guideline_banner_desc_wallet_balance);
      case 'budget_limit':
        return el.tr(CcLocaleKeys.guideline_banner_desc_budget_limit);
      case 'min_living':
        return el.tr(CcLocaleKeys.guideline_banner_desc_min_living);
      case 'first_transaction':
        return el.tr(CcLocaleKeys.guideline_banner_desc_first_transaction);
      case 'investment':
        return el.tr(CcLocaleKeys.guideline_banner_desc_investment);
      case 'liability':
        return el.tr(CcLocaleKeys.guideline_banner_desc_liability);
      case 'lend':
        return el.tr(CcLocaleKeys.guideline_banner_desc_lend);
      default:
        return el.tr(CcLocaleKeys.guideline_banner_desc_default);
    }
  }
}
