import 'package:flutter/cupertino.dart';

/// Reduce boilerplate code if use all paddings for input ui
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
      bottom: bottom,
      left: left,
      right: right,
      top: top,
    ),
    child: w,
  );
}
