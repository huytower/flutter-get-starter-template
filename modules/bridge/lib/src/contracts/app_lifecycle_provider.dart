/// App-level lifecycle work the shell triggers but must not implement itself:
/// presentation bindings after DI, the post-boot background services and the
/// cold-start crash-log upload.
///
/// ```dart
/// unawaited(getIt<AppLifecycleProvider>().initializeUserLevel());
/// ```
abstract interface class AppLifecycleProvider {
  /// Registers the GetX bindings that feature widgets look up with
  /// `Get.find`. Call once, right after DI is initialised.
  void registerPresentationBindings();

  /// Refreshes the user level, which gates what the UI offers.
  Future<void> initializeUserLevel();

  /// Starts the local data services (Firestore watchers, notifications).
  Future<void> initializeDataServices();

  /// Pulls the user's data when the session is authenticated.
  Future<void> syncAuthenticatedData();

  /// Schedules the audit and cloud-backup reminders.
  Future<void> checkReminders();

  /// Uploads a crash log left by a previous session, if any.
  Future<void> uploadPendingCrashLogs();
}
