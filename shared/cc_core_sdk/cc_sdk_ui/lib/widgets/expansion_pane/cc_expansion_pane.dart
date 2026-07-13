import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_base_colors.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';

// Where it helps
// Use it when you need:
//
// collapsible sections in forms or settings
// a compact summary view that expands into details
// a consistent expansion UI across the app
// In short: it helps create a polished accordion/expandable panel with minimal repeated setup.
class CcExpansionPane extends StatefulWidget {
  final Widget collapse;
  final Widget expand;
  final Duration duration;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final bool initiallyExpanded;

  const CcExpansionPane({
    Key? key,
    required this.collapse,
    required this.expand,
    this.duration = const Duration(milliseconds: 200),
    this.backgroundColor = CcBaseColors.white100,
    this.borderRadius,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _ExpansionPaneState createState() => _ExpansionPaneState();
}

class _ExpansionPaneState extends State<CcExpansionPane> {
  var rotate = 1;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: ExpansionTile(
        controlAffinity: ListTileControlAffinity.trailing,
        initiallyExpanded: widget.initiallyExpanded,
        backgroundColor: widget.backgroundColor,
        trailing: RotatedBox(
          quarterTurns: rotate,
          child: SizedBox(
            child: Icon(
              Icons.keyboard_arrow_right,
              size: context.respIconSize(baseSize: 15.0),
            ),
            height: context.respIconSize(baseSize: 15.0),
            width: context.respIconSize(baseSize: 15.0),
          ),
        ),
        tilePadding: EdgeInsets.only(right: context.respPadding(12.0)),
        childrenPadding: EdgeInsets.zero,
        title: widget.collapse,
        children: [widget.expand],
        onExpansionChanged: (value) {
          setState(() {
            if (value) {
              rotate = -1;
            } else {
              rotate = 1;
            }
          });
        },
      ),
    );
  }
}
