import 'dart:ui' show Color;

import 'package:domain_features/export_domain_features.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

/// Forwards to [GuidelineController]. Getters read the controller's `Rx`
/// values, so an enclosing `Obx` still subscribes to them.
@LazySingleton(as: GuidelineProvider)
class GuidelineProviderImpl implements GuidelineProvider {
  GuidelineController get _c => Get.find<GuidelineController>();

  GuidelineController? get _mounted =>
      hasAvailable ? Get.find<GuidelineController>() : null;

  @override
  bool get hasAvailable => Get.isRegistered<GuidelineController>();

  @override
  bool hasTaskActive(String taskId) => _c.hasTaskActive(taskId);

  @override
  bool hasTaskCompleted(String taskId) => _c.hasTaskCompleted(taskId);

  @override
  String? get currentTaskId => _c.currentTaskId;

  @override
  Color get currentColor => _c.currentColor;

  @override
  String get bannerDescription => _c.bannerDescription;

  @override
  int get remainingGuidelineStep => _c.remainingGuidelineStep;

  @override
  bool get hasCreatedFirstInvestment => _c.hasCreatedFirstInvestment.value;

  @override
  bool get hasCreatedFirstLiability => _c.hasCreatedFirstLiability.value;

  @override
  List<String> get completedTasks => _c.completedTasks;

  @override
  int get bounceTrigger => _c.bounceTrigger.value;

  @override
  bool get hasBannerHidden => _c.hasBannerHidden.value;

  @override
  set hasBannerHidden(bool value) => _c.hasBannerHidden.value = value;

  @override
  bool get hasDescriptionHidden => _c.hasDescriptionHidden.value;

  @override
  set hasDescriptionHidden(bool value) => _c.hasDescriptionHidden.value = value;

  @override
  void onCompletedTasksChanged(void Function(List<String> tasks) listener) {
    ever<List<String>>(_c.completedTasks, listener);
  }

  @override
  Future<void> completeTask(String taskId) async =>
      _mounted?.completeTask(taskId);

  @override
  Future<void> setInvestmentCreated() async => _mounted?.setInvestmentCreated();

  @override
  Future<void> setLiabilityCreated() async => _mounted?.setLiabilityCreated();

  @override
  Future<void> resetGuideline() async => _mounted?.resetGuideline();
}
