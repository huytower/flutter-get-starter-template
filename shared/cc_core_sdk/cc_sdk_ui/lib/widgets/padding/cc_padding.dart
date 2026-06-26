import 'package:flutter/cupertino.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';

/// Reduce boilerplate code if use all paddings for input ui.
/// Values passed are considered base values and will be made responsive.
class CcPadding extends StatelessWidget {
  const CcPadding(
    this.w,
    this.bottom,
    this.left,
    this.right,
    this.top, {
    Key? key,
  }) : super(key: key);

  final Widget w;

  final double bottom, left, right, top;

  @override
  Padding build(c) => Padding(
    padding: EdgeInsets.only(
      bottom: c.respPadding(bottom),
      left: c.respPadding(left),
      right: c.respPadding(right),
      top: c.respPadding(top),
    ),
    child: w,
  );
}
