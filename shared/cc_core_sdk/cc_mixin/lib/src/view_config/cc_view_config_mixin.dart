import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Mixin providing reusable view configuration and UI building logic.
///
/// This mixin is designed to be state management agnostic and can be used
/// with different approaches (GetX, Bloc, Provider, Riverpod, etc.).
///
/// ⚠️ IMPORTANT: Do NOT override the standard Flutter [build()] method.
/// Instead, override [buildContent()] to provide your main content widget.
/// The mixin handles the [build()] method internally to provide consistent
/// scaffolding, layout states, and error handling.
///
/// Usage:
/// 1. Override [buildContent] to provide your main content widget (REQUIRED)
/// 2. Customize behavior by overriding optional getters/methods:
///    - [layoutStatus]: Control which layout page is shown
///    - [onRetry]: Hook for retry action on error state
///    - [enableAppBar], [buildAppBar], [floatingActionButton]: Navigation config
///    - [onPageBodyWrapper]: Hook to wrap the body content
///
/// Example:
/// ```dart
/// class MyView extends StatelessWidget with CcViewConfigMixin {
///   @override
///   Widget? buildContent() => Text('Success Content');
/// }
/// ```
mixin CcViewConfigMixin {
  // ============================================
  // Configuration (Optional Overrides)
  // ============================================

  /// Controls whether the app bar is enabled for this view
  bool get enableAppBar => true;

  /// Controls whether the bottom navigation bar is enabled for this view
  bool get enableBottomNavigationBar => true;

  /// Optional floating action button for the view
  Widget? get floatingActionButton =>
      CcFloatingActionButton(onTap: onTapFloatingActionButton, showing: false);

  /// Current layout status that determines which page is shown
  CcLayoutStatus get layoutStatus => CcLayoutStatus.success;

  /// Controls whether the loading page is enabled for this view
  bool get enableLoading => true;

  /// Error message to display in error layout
  /// Override this to provide a localized error message.
  String get errorMessage => 'An error occurred';

  // ============================================
  // Required Methods
  // ============================================

  /// Main content widget for the view.
  /// This is the only method that MUST be overridden.
  Widget? buildContent(BuildContext context);

  // ============================================
  // Hooks (Optional Overrides)
  // ============================================

  /// App bar for the view
  PreferredSizeWidget? buildAppBar(BuildContext context) => AppBar();

  /// Bottom navigation bar for the view
  Widget? buildBottomNavigationBar() => null;

  /// Action handler for the retry button in error state
  void onRetry(BuildContext context) {}

  /// Floating action button tap handler
  void onTapFloatingActionButton() {}

  /// Optional wrapper for the body content.
  /// Useful for adding gradients, background decorations, or padding.
  Widget onPageBodyWrapper(BuildContext context, Widget body) => body;

  // ============================================
  // Build Methods
  // ============================================

  /// Standard Flutter build method.
  /// This method calls [buildView] to construct the UI.
  Widget build(BuildContext context) {
    return buildView(context);
  }

  /// Main build method - builds the complete view with scaffold
  ///
  /// ⚠️ DO NOT OVERRIDE THIS METHOD in your view classes.
  /// This method is called by the base class (e.g., CcGetView) and
  /// handles the complete scaffold structure including app bar, bottom
  /// navigation, floating action button, and body based on layout status.
  ///
  /// To customize your view content, override [buildContent()] instead.
  @mustCallSuper
  Widget buildView(BuildContext context) {
    return Scaffold(
      body: onPageBodyWrapper(context, SafeArea(child: body(context))),
      appBar: enableAppBar ? buildAppBar(context) : null,
      bottomNavigationBar: enableBottomNavigationBar
          ? buildBottomNavigationBar()
          : null,
      floatingActionButton: floatingActionButton,
    );
  }

  /// Returns the body content based on current [layoutStatus]
  ///
  /// Layout mapping:
  /// - [CcLayoutStatus.loading] → Shows loading page
  /// - [CcLayoutStatus.success] → Shows main content from [buildContent]
  /// - [CcLayoutStatus.empty] → Shows empty page
  /// - [CcLayoutStatus.error] → Shows error page with retry
  /// - [CcLayoutStatus.loadMore] → Shows main content (for pagination)
  /// - [CcLayoutStatus.refresh] → Shows loading page
  Widget body(BuildContext context) {
    switch (layoutStatus) {
      case CcLayoutStatus.loading:
        return enableLoading
            ? const LoadingPage()
            : (buildContent(context) ?? const SizedBox.shrink());
      case CcLayoutStatus.loadMore:
        return buildContent(context) ?? const SizedBox.shrink();
      case CcLayoutStatus.success:
        return buildContent(context) ?? const SizedBox.shrink();
      case CcLayoutStatus.empty:
        return const EmptyPage();
      case CcLayoutStatus.error:
        return ErrorPage(
          message: errorMessage,
          onRetry: () => onRetry(context),
        );
      case CcLayoutStatus.refresh:
        return enableLoading
            ? const LoadingPage()
            : (buildContent(context) ?? const SizedBox.shrink());
    }
  }
}
