import 'package:app_config/export_app_config.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import 'guideline_success_dialog.dart';

@lazySingleton
class GuidelineController extends GetxController {
  final List<String> taskSequence = [
    'birth_year', // Profile -> _pickBirthYear
    'categories', // Profile -> CategorySettingsPage
    'wallet_balance', // Budget Allocation -> AddWalletSheet (Cash)
    'reconcile_wallet', // Budget Allocation -> ReconcilePage
    'budget_limit', // Budget Allocation -> BudgetLimitPage
    'min_living', // Budget Allocation -> AddBudgetLimitForm (storm icon)
    'first_transaction', // Transaction -> ExpenseForm
  ];

  final Map<String, Color> taskColors = {
    'birth_year': Colors.purple,
    'categories': Colors.deepOrange,
    'wallet_balance': Colors.indigo,
    'reconcile_wallet': Colors.pinkAccent,
    'budget_limit': Colors.cyan,
    'min_living': Colors.amber,
    'first_transaction': Colors.pink,
  };

  final RxList<String> completedTasks = <String>[].obs;

  /// Trigger for the bounce animation on the tab bar.
  final RxInt bounceTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = CcAppStorage.instance.completedGuidelineTaskIds;
    if (saved != null) {
      completedTasks.assignAll(saved);
    }
  }

  bool isTaskCompleted(String taskId) => completedTasks.contains(taskId);

  String? get currentTaskId {
    for (final taskId in taskSequence) {
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
        activeId == 'reconcile_wallet' ||
        activeId == 'budget_limit' ||
        activeId == 'min_living') {
      return 0; // Budget Allocation tab
    }
    if (activeId == 'first_transaction') {
      return 1; // Transaction tab
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

    if (currentTaskId == null) {
      // All tasks completed! Show the congrats dialog.
      Get.dialog(const GuidelineSuccessDialog(), barrierDismissible: true);
    }
  }

  /// Resets all completed guideline tasks, showing the guide banner again.
  Future<void> resetGuideline() async {
    completedTasks.clear();
    CcAppStorage.instance.completedGuidelineTaskIds = [];
    await CcAppStorage.instance.save();
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
      case 'reconcile_wallet':
        return el.tr(CcLocaleKeys.guideline_banner_desc_modify_cash);
      case 'budget_limit':
        return el.tr(CcLocaleKeys.guideline_banner_desc_budget_limit);
      case 'min_living':
        return el.tr(CcLocaleKeys.guideline_banner_desc_min_living);
      case 'first_transaction':
        return el.tr(CcLocaleKeys.guideline_banner_desc_first_transaction);
      default:
        return el.tr(CcLocaleKeys.guideline_banner_desc_default);
    }
  }
}
