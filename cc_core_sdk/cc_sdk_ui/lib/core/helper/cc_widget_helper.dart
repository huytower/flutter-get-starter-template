import 'package:cc_sdk/core/helper/cc_device_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../config/tokens/cc_circular_params.dart';
import '../extensions/cc_context_extension.dart';

/// CcWidgetHelper: Utility class for common UI-related operations and styling.
///
/// Principles:
/// - State-management agnostic.
/// - Prioritize design tokens for colors and typography.
/// - Consolidate platform and device logic into `cc_sdk` helpers.
class CcWidgetHelper {
  // ==========================================================================
  // SHADOWS & BORDERS
  // ==========================================================================

  /// MUST set these orders, to avoid transparent with drop shadow issue
  static List<BoxShadow> getBoxShadows(
    BuildContext context, {
    Color? shadowColor,
    double? x,
    double? y,
    double? blurRadius,
    double? spreadRadius,
    Color? bgColor,
  }) => [
    /// 2 - drop background of child widget
    BoxShadow(
      color: shadowColor ?? context.ccColorScheme.outlineVariant,
      spreadRadius: spreadRadius ?? 0.0,
      blurRadius: blurRadius ?? 3.0,
      offset: Offset(x ?? 2.0, y ?? 2.0),
    ),

    /// 1 - below background of child widget,
    BoxShadow(
      color: bgColor ?? Colors.white,
      spreadRadius: 0,
      blurRadius: 0,
      offset: Offset.zero,
    ),
  ];

  static BorderRadius getCircleBorderRadius() =>
      BorderRadius.circular(CcCircularParams.CIRCLE);

  static BorderRadius getBorderRoundedLG() =>
      BorderRadius.circular(CcCircularParams.CARD);

  static BorderRadius getBorderRoundedMD() =>
      BorderRadius.circular(CcCircularParams.BUTTON);

  static BorderRadius getBorderRoundedSM() =>
      BorderRadius.circular(CcCircularParams.BUTTON);

  static BorderRadius getBorderRoundedSquareTopLeftRight() =>
      const BorderRadius.only(
        topLeft: Radius.circular(CcCircularParams.SQUARE_TOP),
        topRight: Radius.circular(CcCircularParams.SQUARE_TOP),
      );

  // ==========================================================================
  // LAYOUT HELPERS
  // ==========================================================================

  /// Determines the appropriate BoxFit based on presentation dimensions
  ///
  /// [screenWidth] - The width of the presentation in logical pixels
  /// [bottomPadding] - The bottom padding from MediaQuery
  static BoxFit getBoxFitType({
    required double screenWidth,
    required double bottomPadding,
  }) {
    if (CcDeviceHelper.isLargeScreen(
      screenWidth: screenWidth,
      bottomPadding: bottomPadding,
    )) {
      return BoxFit.fill;
    }
    return BoxFit.cover;
  }

  // ==========================================================================
  // SCROLLING HELPERS
  // ==========================================================================

  /// Scroll notification method, click
  static bool isScrollingClickEnd(ScrollNotification scrollState) =>
      scrollState is ScrollEndNotification;

  /// Scroll notification method, click
  static bool isScrollingClickStart(ScrollNotification scrollState) =>
      scrollState is ScrollStartNotification;

  /// Scroll notification method, while scrolling
  static bool isScrollingToEnd(ScrollNotification scrollState) =>
      scrollState is UserScrollNotification &&
      scrollState.direction == ScrollDirection.idle;

  /// Make input scroll controller scroll to top
  /// Returns true if scroll was successful, false otherwise
  static bool scrollToTop(ScrollController scrollController) {
    try {
      if (scrollController.hasClients &&
          scrollController.position.hasContentDimensions) {
        scrollController.animateTo(
          0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================================
  // FRAME & LIFECYCLE HELPERS
  // ==========================================================================

  /// Safely mark widget for rebuild after current frame
  /// Returns true if callback was scheduled successfully
  static bool markNeedsBuild(VoidCallback callback) {
    try {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        try {
          callback();
        } catch (e) {
          debugPrint('Error in post frame callback: $e');
        }
      });
      return true;
    } catch (e) {
      debugPrint('Error scheduling post frame callback: $e');
      return false;
    }
  }
}
