import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// A fixed-height horizontal scroll area that fades its edges based on
/// scroll position.
///
/// - Left edge fades only when scrolled away from the start.
/// - Right edge fades only when there is more content to the right.
/// - Neither edge fades when the content fits entirely without scrolling.
///
/// Pass the provided [ScrollController] to the [ListView] (or
/// [SingleChildScrollView]) built inside [builder].
class HorizontalFadeScrollView extends StatefulWidget {
  final double height;
  final Widget Function(ScrollController controller) builder;

  const HorizontalFadeScrollView({
    super.key,
    required this.height,
    required this.builder,
  });

  @override
  State<HorizontalFadeScrollView> createState() =>
      _HorizontalFadeScrollViewState();
}

class _HorizontalFadeScrollViewState extends State<HorizontalFadeScrollView> {
  final _controller = ScrollController();
  bool _fadeLeft = false;
  bool _fadeRight = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    final newLeft = pos.pixels > 0;
    final newRight = pos.pixels < pos.maxScrollExtent;
    if (newLeft != _fadeLeft || newRight != _fadeRight) {
      setState(() {
        _fadeLeft = newLeft;
        _fadeRight = newRight;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          _fadeLeft ? Colors.transparent : context.ccColorScheme.surface,
          context.ccColorScheme.surface,
          context.ccColorScheme.surface,
          _fadeRight ? Colors.transparent : context.ccColorScheme.surface,
        ],
        stops: const [0.0, 0.08, 0.88, 1.0],
      ).createShader(bounds),
      child: SizedBox(
        height: widget.height,
        child: widget.builder(_controller),
      ),
    );
  }
}
