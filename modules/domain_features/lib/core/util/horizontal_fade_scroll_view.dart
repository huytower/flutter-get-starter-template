import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Compatibility wrapper for the shared horizontal fade scroll view.
class HorizontalFadeScrollView extends StatelessWidget {
  final double height;
  final Widget Function(ScrollController controller) builder;

  const HorizontalFadeScrollView({
    super.key,
    required this.height,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return cc_sdk_ui.widgets.scroll.horizontal_fade_scroll_view.HorizontalFadeScrollView(
      height: height,
      builder: builder,
    );
  }
}
