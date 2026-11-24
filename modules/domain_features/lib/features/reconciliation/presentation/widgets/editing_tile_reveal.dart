import 'package:flutter/material.dart';

/// Scrolls [child] fully into view when [hasEditing] turns on.
///
/// Editing a wallet amount brings up the money keypad under the list, which
/// shrinks the scroll viewport (or, on tablets, reserves bottom padding for
/// the floating keypad). A tile low on the page would then sit behind the
/// keypad, so the user could not see the amount being typed. The scroll runs
/// after the frame that shows the keypad, once the viewport has its new size,
/// and only moves the list when the tile's bottom is actually hidden.
class EditingTileReveal extends StatefulWidget {
  final bool hasEditing;
  final Widget child;

  const EditingTileReveal({
    super.key,
    required this.hasEditing,
    required this.child,
  });

  @override
  State<EditingTileReveal> createState() => _EditingTileRevealState();
}

class _EditingTileRevealState extends State<EditingTileReveal> {
  static const Duration _scrollDuration = Duration(milliseconds: 250);

  @override
  void didUpdateWidget(covariant EditingTileReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasEditing && !oldWidget.hasEditing) _revealAfterLayout();
  }

  void _revealAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.hasEditing) return;
      Scrollable.ensureVisible(
        context,
        duration: _scrollDuration,
        curve: Curves.easeOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
