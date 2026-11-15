import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Caps the app's content width on very wide screens (large tablets, iPad Pro,
/// landscape tablets) so the phone-first layout stays a centred column instead
/// of stretching edge to edge.
///
/// Phones and medium tablets (< [maxContentWidth], Material "medium" window
/// class) are untouched: the child is returned as-is.
///
/// The [MediaQuery] size is overridden too, so everything that scales from the
/// screen width (`respDim`, `respPadding`, `ccTextTheme`, breakpoints) behaves
/// as if the device were exactly [maxContentWidth] wide — the layout stays
/// consistent and never "double scales" on huge screens.
class AppContentFrame extends StatelessWidget {
  /// Upper bound of Material's "medium" window class (dp).
  static const double maxContentWidth = 840;

  final Widget child;

  const AppContentFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.size.width <= maxContentWidth) return child;

    final width = math.min(mediaQuery.size.width, maxContentWidth);
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
