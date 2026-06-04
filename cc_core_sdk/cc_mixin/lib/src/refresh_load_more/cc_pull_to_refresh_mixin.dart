import 'package:cc_sdk_ui/core/extensions/common/cc_responsive_extension.dart';
import 'package:cc_sdk_ui/widgets/pull_to_refresh/cc_refresh_indicator.dart';
import 'package:cc_sdk_ui/widgets/pull_to_refresh/cc_refresh_indicator_icon.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

/// Mixin providing pull-to-refresh functionality that is state-management agnostic.
///
/// This mixin provides a standardized implementation of pull-to-refresh
/// that can be used across different views and state management approaches (Bloc, GetX, Provider, etc.).
///
/// The mixin is state-management agnostic and provides:
/// - Customizable loading and complete widgets
/// - Configurable animation durations and sizes
/// - Optional controller for programmatic control
/// - State change callbacks for analytics/tracking
///
/// Usage with GetX:
/// ```dart
/// class MyGetXView extends GetView<MyController> with CcPullRefreshMixin {
///   @override
///   Widget build(BuildContext context) {
///     return buildPullToRefresh(
///       onRefresh: controller.refreshData,
///       child: ListView(...),
///     );
///   }
/// }
/// ```
///
/// Usage with Bloc:
/// ```dart
/// class MyBlocView extends StatelessWidget with CcPullRefreshMixin {
///   @override
///   Widget build(BuildContext context) {
///     return buildPullToRefresh(
///       onRefresh: () => context.read<MyBloc>().add(RefreshData()),
///       child: ListView(...),
///     );
///   }
/// }
/// ```
///
/// Custom loading widget:
/// ```dart
/// buildPullToRefresh(
///   onRefresh: _refresh,
///   icLoadingWidget: CircularProgressIndicator(),
///   icCompleteWidget: Icon(Icons.check_circle),
///   child: ListView(...),
/// )
/// ```
mixin CcPullRefreshMixin {
  /// Default image size for the indicator icons (base size for mobile)
  /// On larger screens, this scales using respIconSize formula
  double get defaultImageSize => 40.0;

  /// Default indicator size (the space allocated for the indicator, base size for mobile)
  /// On larger screens, this scales using respIconSize formula
  double get defaultIndicatorSize => 80.0;

  /// Default loading widget shown during refresh
  /// Override this to provide a custom loading widget
  /// Note: This widget uses a responsive extension method when context is available.
  /// For responsive sizing, pass a BuildContext to buildPullToRefresh.
  Widget get defaultLoadingWidget => const SizedBox(
    width: 24,
    height: 24,
    child: CircularProgressIndicator(strokeWidth: 2),
  );

  /// Default complete widget shown after refresh completes
  /// Override this to provide a custom complete widget
  /// Note: This widget uses a responsive extension method when context is available.
  /// For responsive sizing, pass a BuildContext to buildPullToRefresh.
  Widget get defaultCompleteWidget =>
      const Icon(Icons.check_circle, color: PrjColors.success, size: 24);

  /// Default duration to show the complete state
  Duration get defaultCompleteStateDuration =>
      const Duration(milliseconds: 100);

  /// Builds the loading widget with optional custom widget
  Widget buildLoadingWidget(Widget? customLoadingWidget) {
    return customLoadingWidget ?? defaultLoadingWidget;
  }

  /// Builds the complete widget with optional custom widget
  Widget buildCompleteWidget(Widget? customCompleteWidget) {
    return customCompleteWidget ?? defaultCompleteWidget;
  }

  /// Callback for indicator state changes
  /// Override this for analytics/tracking purposes
  /// Example: Firebase Analytics tracking of refresh states
  void onIndicatorStateChanged(IndicatorStateChange change) {
    // Override to implement analytics tracking
    // Example:
    // FirebaseAnalytics().logEvent(name: 'refresh_state', parameters: {
    //   'from': change.from.name,
    //   'to': change.to.name,
    // });
  }

  /// Builds a pull-to-refresh wrapper around a child widget with optional responsive sizing.
  ///
  /// ## Responsive Sizing
  ///
  /// When [context] is provided, the mixin uses responsive sizing formulas:
  /// - `imageSize` scales: baseSize * (screenWidth / 360).clamp(1.0, 2.0)
  /// - `indicatorSize` scales: baseSize * (screenWidth / 360).clamp(1.0, 2.0)
  ///
  /// Without context, sizes default to hardcoded mobile values (backward compatible).
  ///
  /// ## Parameters:
  /// - [onRefresh]: Required callback when refresh is triggered
  /// - [child]: The scrollable child widget
  /// - [context]: Optional BuildContext for responsive sizing (recommended)
  /// - [controller]: Optional controller for programmatic control
  /// - [onCancel]: Optional callback when refresh is cancelled during loading
  /// - [icLoadingWidget]: Custom loading widget (overrides default)
  /// - [icCompleteWidget]: Custom complete widget (overrides default)
  /// - [imageSize]: Size of the indicator icons (auto-responsive if context provided)
  /// - [indicatorSize]: Space allocated for the indicator (auto-responsive if context provided)
  /// - [completeStateDuration]: Duration to show complete state
  /// - [trigger]: Which edge triggers the refresh (default: leadingEdge)
  /// - [triggerMode]: How the refresh can be triggered (default: onEdge)
  /// - [scrollDirection]: Scroll direction (default: vertical)
  ///
  /// ## Example with responsive sizing:
  /// ```dart
  /// buildPullToRefresh(
  ///   context: context,  // Pass context for responsive sizes
  ///   onRefresh: _refresh,
  ///   child: ListView(...),
  /// )
  /// ```
  Widget buildPullToRefresh({
    required Future<void> Function() onRefresh,
    required Widget child,
    BuildContext? context,
    CcIndicatorController? controller,
    Future<void> Function()? onCancel,
    Widget? icLoadingWidget,
    Widget? icCompleteWidget,
    double? imageSize,
    double? indicatorSize,
    Duration? completeStateDuration,
    IndicatorTrigger? trigger,
    IndicatorTriggerMode? triggerMode,
    Axis? scrollDirection,
  }) {
    // Compute responsive sizes if context is available
    final responsiveImageSize =
        imageSize ??
        (context != null
            ? context.respIconSize(baseSize: defaultImageSize)
            : defaultImageSize);
    final responsiveIndicatorSize =
        indicatorSize ??
        (context != null
            ? context.respIconSize(baseSize: defaultIndicatorSize)
            : defaultIndicatorSize);

    return CcCustomRefreshIndicator(
      controller: controller,
      onCancel: onCancel,
      onRefresh: onRefresh,
      onStateChanged: onIndicatorStateChanged,
      completeStateDuration:
          completeStateDuration ?? defaultCompleteStateDuration,
      trigger: trigger ?? IndicatorTrigger.leadingEdge,
      triggerMode: triggerMode ?? IndicatorTriggerMode.onEdge,
      scrollDirection: scrollDirection ?? Axis.vertical,
      builder: (context, child, controller) => _buildIndicatorIcon(
        child: child,
        controller: controller,
        imageSize: responsiveImageSize,
        indicatorSize: responsiveIndicatorSize,
        icLoadingWidget: buildLoadingWidget(icLoadingWidget),
        icCompleteWidget: buildCompleteWidget(icCompleteWidget),
      ),
      child: child,
    );
  }

  /// Builds the refresh indicator icon widget
  CcRefreshIndicatorIcon _buildIndicatorIcon({
    required Widget child,
    required CcIndicatorController controller,
    required double imageSize,
    required double indicatorSize,
    required Widget icLoadingWidget,
    required Widget icCompleteWidget,
  }) {
    return CcRefreshIndicatorIcon(
      controller: controller,
      imageSize: imageSize,
      indicatorSize: indicatorSize,
      icLoadingWidget: icLoadingWidget,
      icCompleteWidget: icCompleteWidget,
      child: child,
    );
  }
}
