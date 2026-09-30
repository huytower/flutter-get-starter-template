/// Outcome of [FinancialDataSyncService.logoutSafely].
enum LogoutResult {
  /// Signed out. Every record was verified as synced first, so the on-disk
  /// financial cache was cleared and the next account starts from empty.
  success,

  /// Device is offline — refusing so unsynced records are never abandoned.
  offline,

  /// Records remain unsynced after a sync attempt — refusing so the user
  /// stays signed in and can retry or discard.
  pendingSync,
}
