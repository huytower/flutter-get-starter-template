/// [CcLayoutStatus] defines the core UI lifecycle states for the application.
///
/// It acts as a bridge between business logic results and the Presentation layer,
/// allowing widgets to reactively switch layouts based on the current process state.
enum CcLayoutStatus {
  /// The component is currently fetching or processing data.
  /// Typically shows a spinner or skeleton.
  loading,

  /// Used during pagination when more items are being appended to an existing list.
  loadMore,

  /// Data processing completed successfully. The UI should display the content.
  success,

  /// Data processing completed successfully, but the result set is empty.
  /// Typically shows an "Empty State" illustration.
  empty,

  /// An error occurred during the lifecycle (Network, Server, or Logic).
  /// Typically shows an error page or retry button.
  error,

  /// Optional state used when a manual refresh or hard-reload is triggered.
  refresh,
}
