import 'package:flutter/material.dart';

/// A reusable widget that provides a bounce animation on tap.
/// Wraps any child widget with a scale animation that bounces when tapped.
class CcBounceAnimation extends StatefulWidget {
  /// The child widget to wrap with bounce animation.
  final Widget child;

  /// The callback to execute when tapped.
  final VoidCallback onTap;

  /// The scale factor when pressed (default: 0.9).
  final double pressedScale;

  /// The duration of the animation (default: 150ms).
  final Duration duration;

  const CcBounceAnimation({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.9,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<CcBounceAnimation> createState() => _CcBounceAnimationState();
}

class _CcBounceAnimationState extends State<CcBounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      ),
    );
  }
}
