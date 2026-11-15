import 'dart:math' as math;

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/material.dart';

/// Caps the whole app at [maxAppWidth] on desktop-class windows (web / desktop
/// wider than 1200 dp) so nothing stretches across a full monitor.
///
/// Every phone and tablet — including a 10" tablet in landscape up to
/// 1200 dp — is below the cap and gets the child untouched. Within the cap,
/// the navigation shell decides its own layout (rail + width-capped content);
/// see `NavigationBar`.
///
/// The [MediaQuery] size is overridden to the capped width, so window-based
/// decisions (`context.windowSizeClass`, `respDim`, `ccTextTheme`) agree with
/// the space the app really has.
class AppContentFrame extends StatelessWidget {
  /// Lower bound of Material's "large" window class (dp).
  static final double maxAppWidth = CcWindowSizeClass.large.minWidth;

  final Widget child;

  const AppContentFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.size.width <= maxAppWidth) return child;

    final width = math.min(mediaQuery.size.width, maxAppWidth);
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: width,
          child: MediaQuery(
            // Side insets (landscape notch/gesture areas) fall in the gutters,
            // not inside the centred column.
            data: mediaQuery.copyWith(
              size: Size(width, mediaQuery.size.height),
              padding: mediaQuery.padding.copyWith(left: 0, right: 0),
              viewPadding: mediaQuery.viewPadding.copyWith(left: 0, right: 0),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
