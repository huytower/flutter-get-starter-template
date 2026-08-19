import 'dart:async';

import 'package:app_config/export_app_config.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../wallet/domain/entities/wallet_entity.dart';
import '../wallet/presentation/get_x/wallet_controller.dart';
import '../user_level/presentation/get_x/user_level_controller.dart';
import 'guideline_success_dialog.dart';

@lazySingleton
class GuidelineController extends GetxController {
  GuidelineController(this._userLevelController);

  final UserLevelController _userLevelController;

  final List<String> taskSequence = [
    'birth_year', // Profile -> _pickBirthYear
    'categories', // Profile -> CategorySettingsPage
    'wallet_balance', // Liquid Wallet List -> Edit Cash Wallet
    'budget_limit', // Budget Allocation -> BudgetLimitPage
    'min_living', // Budget Allocation -> AddBudgetLimitForm (storm icon)
    'first_transaction', // Transaction -> ExpenseForm
    'investment', // Budget Allocation -> Add Investment + Transaction -> Investment tab
  ];

  final Map<String, Color> taskColors = {
    'birth_year': Colors.purple,
    'categories': Colors.deepOrange,
    'wallet_balance': Colors.indigo,
    'budget_limit': Colors.cyan,
    'min_living': Colors.amber,
    'first_transaction': Colors.pink,
    'investment': Colors.green,
  };

  final RxList<String> completedTasks = <String>[].obs;

  /// Trigger for the bounce animation on the tab bar.
  final RxInt bounceTrigger = 0.obs;

  /// True once the user has created their first investment position.
  /// Controls where the investment guideline badge points:
  /// - false -> Budget Allocation tab + Add Investment button
  /// - true  -> Transaction tab + Investment record
  final RxBool hasCreatedFirstInvestment = false.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = CcAppStorage.instance.completedGuidelineTaskIds;
    if (saved != null) {
      completedTasks.assignAll(saved);
    }
    _restoreInvestmentStatus();
  }

  Future<void> _restoreInvestmentStatus() async {
    if (currentTaskId != 'investment') return;
    if (hasCreatedFirstInvestment.value) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('has_created_first_investment') ?? false) {
      hasCreatedFirstInvestment.value = true;
      return;
    }

    try {
      final walletController = getIt<WalletController>();
      if (walletController.wallets.any((w) => w.type == WalletType.investment)) {
        hasCreatedFirstInvestment.value = true;
        await prefs.setBool('has_created_first_investment', true);
      }
    } catch (_) {
      // WalletController not ready yet; will be checked on next signal.
    }
  }

  bool isTaskCompleted(String taskId) => completedTasks.contains(taskId);

  String? get currentTaskId {
    final level = _userLevelController.status.value.level;
    for (final taskId in taskSequence) {
      if (taskId == 'investment' && level < 2) continue;
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

  /// Resets all completed guideline tasks, showing the guide banner again.
  Future<void> resetGuideline() async {
    completedTasks.clear();
    CcAppStorage.instance.completedGuidelineTaskIds = [];
    await CcAppStorage.instance.save();
    hasCreatedFirstInvestment.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_created_first_investment');
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
      default:
        return el.tr(CcLocaleKeys.guideline_banner_desc_default);
    }
  }
}
