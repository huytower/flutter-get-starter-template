import 'dart:ui' show Color;

/// The onboarding guideline (current task, badge colour, banner) for features
/// other than guideline itself; implemented by the App orchestrator
/// (`modules/bridge`).
///
/// Getters are reactive: read them inside `Obx` and the widget rebuilds when
/// the guideline moves on. The writes ([completeTask], `set*Created`) are
/// no-ops while the guideline is not mounted ([hasAvailable] is false); the
/// reads expect it to be mounted, as the guideline is registered at startup.
///
/// ```dart
/// if (guideline.isTaskActive('investment')) { ... }
/// getIt<GuidelineProvider>().completeTask('liability');
/// ```
abstract class GuidelineProvider {
  bool get hasAvailable;

  bool isTaskActive(String taskId);

  bool isTaskCompleted(String taskId);

  String? get currentTaskId;

  Color get currentColor;

  String get bannerDescription;

  int get remainingGuidelineStep;

  bool get hasCreatedFirstInvestment;

  bool get hasCreatedFirstLiability;

  List<String> get completedTasks;

  /// Bumped to make the active badge bounce.
  int get bounceTrigger;

  bool get hasBannerHidden;
  set hasBannerHidden(bool value);

  bool get hasDescriptionHidden;
  set hasDescriptionHidden(bool value);

  /// Calls [listener] every time the completed task list changes.
  void onCompletedTasksChanged(void Function(List<String> tasks) listener);

  Future<void> completeTask(String taskId);

  Future<void> setInvestmentCreated();

  Future<void> setLiabilityCreated();

  Future<void> resetGuideline();
}
