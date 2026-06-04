import 'package:flutter/material.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';

class IconHeart extends StatelessWidget {
  const IconHeart({
    Key? key,
    this.height,
    this.width,
    this.colors,
    this.isCircleIcon = false,
  }) : super(key: key);

  final double? height, width;

  final List<Color>? colors;

  final bool isCircleIcon;

  @override
  Widget build(BuildContext context) =>
      isCircleIcon ? getCircleIcon(context) : getIcon(context);

  Widget getIcon(BuildContext context) => ShaderMask(
    shaderCallback: (Rect bounds) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors:
            colors ??
            [context.ccColorScheme.primary, context.ccColorScheme.primary],
      ).createShader(bounds);
    },
    child: Icon(
      Icons.favorite,
      color: Colors.white,
      size: height ?? context.respIconSize(baseSize: 20.0),
    ),
  );

  Widget getCircleIcon(BuildContext context) => Container(
    width: width ?? 30,
    height: height ?? 30,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: getIcon(context),
  );
}
