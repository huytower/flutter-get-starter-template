import 'package:app_config/export_app_config.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
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
    'budget_limit', // Budget Allocation -> BudgetLimitPage
    'min_living', // Budget Allocation -> AddBudgetLimitForm (storm icon)
    'first_transaction', // Transaction -> ExpenseForm
  ];

  final Map<String, Color> taskColors = {
    'birth_year': Colors.purple,
    'categories': Colors.deepOrange,
    'wallet_balance': Colors.indigo,
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

    'Task completed: $taskId. Next: $currentTaskId'.Log('GuidelineController');

    if (currentTaskId == null) {
      // All tasks completed! Show the congrats dialog.
      Get.dialog(const GuidelineSuccessDialog(), barrierDismissible: true);
    }
  }

  String get bannerTitle {
    if (currentTaskId == null) {
      return 'Chúc mừng! Bạn đã hoàn thành các bước hướng dẫn thiết lập.';
    }
    return 'Hướng dẫn: Bước $currentStep/${taskSequence.length}';
  }

  String get bannerDescription {
    if (currentTaskId == null) {
      return 'Bây giờ bạn có thể bắt đầu quản lý tài chính một cách kỷ luật.';
    }
    switch (currentTaskId) {
      case 'birth_year':
        return 'Thiết lập năm sinh để nhận gợi ý phù hợp';
      case 'categories':
        return 'Lựa chọn danh mục chi tiêu & thu nhập';
      case 'wallet_balance':
        return 'Thiết lập số dư hiện tại cho Ví';
      case 'budget_limit':
        return 'Đặt ngân sách chi tiêu cho từng danh mục';
      case 'min_living':
        return 'Xác định mức sống tối thiểu hàng tháng';
      case 'first_transaction':
        return 'Ghi chép giao dịch chi tiêu đầu tiên';
      default:
        return 'Bạn đã sẵn sàng quản lý tài chính!';
    }
  }
}
