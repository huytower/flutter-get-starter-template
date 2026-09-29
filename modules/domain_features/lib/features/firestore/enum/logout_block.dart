/// Why sign-out is currently unavailable.
enum LogoutBlock {
  /// No connectivity, so pending records could not be uploaded.
  offline,

  /// Local records have not reached the cloud yet.
  pendingSync,
}
