import 'package:flutter/cupertino.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';

class CcPositionBottom extends StatelessWidget {
  final double? bottom;
  final Widget child;

  const CcPositionBottom({super.key, required this.child, this.bottom});

  @override
  Widget build(BuildContext context) => Positioned(
    bottom: context.respPadding(bottom ?? 0),
    left: 0,
    right: 0,
    child: child,
  );
}

class CcPositionCenter extends StatelessWidget {
  final Widget child;

  const CcPositionCenter({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Positioned.fill(child: child);
}

class CcPositionRight extends StatelessWidget {
  final double? right;
  final Widget child;

  const CcPositionRight({super.key, required this.child, this.right});

  @override
  Widget build(BuildContext context) => Positioned(
    bottom: 0,
    right: context.respPadding(right ?? 0),
    top: 0,
    child: child,
  );
}

class CcPositionTop extends StatelessWidget {
  final Widget child;

  const CcPositionTop({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      Positioned(left: 0, right: 0, top: 0, child: child);
}
