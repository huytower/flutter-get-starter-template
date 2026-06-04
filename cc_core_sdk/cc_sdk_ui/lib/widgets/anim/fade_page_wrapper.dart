import 'package:flutter/material.dart';

import 'fade_widget.dart';

/// A wrapper widget that applies fade animation to page content.
/// Use this to wrap page content for fade-in effect when page loads.
class FadePageWrapper extends StatefulWidget {
  final Widget child;

  const FadePageWrapper({super.key, required this.child});

  @override
  State<FadePageWrapper> createState() => _FadePageWrapperState();
}

class _FadePageWrapperState extends State<FadePageWrapper>
    with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Trigger fade-in animation after widget is built
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeWidget(visible: _visible, child: widget.child);
  }
}
