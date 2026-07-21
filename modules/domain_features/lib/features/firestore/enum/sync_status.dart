/// Represents the synchronization status of an entity.
enum SyncStatus {
  /// Entity has not been synced to the cloud yet.
  pending,

  /// Entity is currently being synced to the cloud.
  syncing,

  /// Entity has been successfully synced to the cloud.
  synced,

  /// Sync failed and needs to be retried.
  failed,

  /// Entity has local changes that need to be synced.
  hasLocalChanges,
}
