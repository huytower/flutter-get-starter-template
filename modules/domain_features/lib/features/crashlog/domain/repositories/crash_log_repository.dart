/// Persists and uploads on-device crash logs.
abstract class CrashLogRepository {
  /// Uploads pending file logs from a previous session; clears file on success.
  Future<bool> uploadPendingOnRestart();
}
