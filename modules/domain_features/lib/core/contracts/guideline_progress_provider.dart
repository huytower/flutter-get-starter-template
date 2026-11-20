/// Records onboarding-guideline progress from any feature without importing
/// the guideline controller; implemented by the App orchestrator
/// (`modules/bridge`). No-op while the guideline is not mounted.
///
/// ```dart
/// getIt<GuidelineProgressProvider>().completeTask('liability');
/// ```
abstract class GuidelineProgressProvider {
  Future<void> completeTask(String taskId);

  Future<void> setInvestmentCreated();

  Future<void> setLiabilityCreated();
}
