import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 3D flashcard-style flip widget that rotates between [front] and [back].
///
/// Defaults to an up-down flip around the X-axis ([Axis.vertical]), matching
/// the vertical flashcard interaction used on list and grid cards.
class PrjFlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Axis flipAxis;
  final bool enabled;
  final Duration duration;

  const PrjFlipCard({
    super.key,
    required this.front,
    required this.back,
    this.flipAxis = Axis.vertical,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<PrjFlipCard> createState() => _PrjFlipCardState();
}

class _PrjFlipCardState extends State<PrjFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _hasFrontVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (!widget.enabled || _controller.isAnimating) return;

    if (_hasFrontVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _hasFrontVisible = !_hasFrontVisible;
    });
  }

  Matrix4 _buildTransform(double angle) {
    final matrix = Matrix4.identity()..setEntry(3, 2, 0.001);
    if (widget.flipAxis == Axis.vertical) {
      matrix.rotateX(angle);
    } else {
      matrix.rotateY(angle);
    }
    return matrix;
  }

  Matrix4 _buildBackCorrection() {
    final matrix = Matrix4.identity();
    if (widget.flipAxis == Axis.vertical) {
      matrix.rotateX(math.pi);
    } else {
      matrix.rotateY(math.pi);
    }
    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? _toggleFlip : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * math.pi;
          final hasUnder = angle > (math.pi / 2);

          return Transform(
            transform: _buildTransform(angle),
            alignment: Alignment.center,
            child: hasUnder
                ? Transform(
                    transform: _buildBackCorrection(),
                    alignment: Alignment.center,
                    child: widget.back,
                  )
                : widget.front,
          );
        },
      ),
    );
  }
}

