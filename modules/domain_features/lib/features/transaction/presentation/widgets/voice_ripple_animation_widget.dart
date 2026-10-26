import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Animated ripple ring widget displaying an expanding concentric pulse
/// around the active microphone icon during voice dictation.
class VoiceRippleAnimationWidget extends StatefulWidget {
  const VoiceRippleAnimationWidget({
    super.key,
    required this.activeColor,
    required this.onTap,
    required this.size,
  });

  final Color activeColor;
  final VoidCallback onTap;
  final double size;

  @override
  State<VoiceRippleAnimationWidget> createState() =>
      _VoiceRippleAnimationWidgetState();
}

class _VoiceRippleAnimationWidgetState
    extends State<VoiceRippleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress1 = _controller.value;
          final progress2 = (progress1 + 0.5) % 1.0;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Outer expanding ripple ring 1
              _buildRippleRing(progress1),
              // Inner expanding ripple ring 2
              _buildRippleRing(progress2),
              // Center button with soft active background
              CcBouncing(
                onTap: widget.onTap,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.activeColor.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mic_rounded,
                      color: widget.activeColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRippleRing(double progress) {
    final scale = 1.0 + (progress * 0.7);
    final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.45;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.activeColor.withOpacity(opacity),
            width: 1.5,
          ),
          color: widget.activeColor.withOpacity(opacity * 0.25),
        ),
      ),
    );
  }
}
