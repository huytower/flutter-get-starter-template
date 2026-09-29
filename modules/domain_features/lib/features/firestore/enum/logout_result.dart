/// Outcome of [FinancialDataSyncService.logoutSafely].
enum LogoutResult {
  /// Signed out. The on-disk cache was preserved.
  success,

  /// Device is offline — refusing so unsynced records are never abandoned.
  offline,

  /// Records remain unsynced after a sync attempt — refusing so the user
  /// stays signed in and can retry or discard.
  pendingSync,
}
