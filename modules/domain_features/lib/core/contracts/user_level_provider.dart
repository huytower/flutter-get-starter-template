import '../domain/entities/user_level_status_entity.dart';

/// The user's current LV1/LV2/LV3 unlock state, for features other than
/// profile; implemented by the App orchestrator (`modules/bridge`).
///
/// [status] is reactive: read it inside `Obx` and the widget rebuilds when the
/// level changes.
///
/// ```dart
/// if (!_userLevel.status.canUseAiSmartEntry) return;
/// ```
abstract class UserLevelProvider {
  UserLevelStatusEntity get status;

  /// Re-evaluates the level after an action that may have changed it.
  Future<void> refresh();
}
