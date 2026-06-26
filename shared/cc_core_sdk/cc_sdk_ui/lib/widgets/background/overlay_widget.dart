import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';

class OverlayWidget extends StatelessWidget {
  const OverlayWidget({Key? key, this.color, this.opacity = 0.5})
    : super(key: key);

  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Container(
      color: (color ?? context.ccColorScheme.surfaceVariant).withOpacity(
        opacity,
      ),
    ),
  );
}
