import 'package:cc_sdk/core/helper/cc_image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';
import '../inkwell/cc_inkwell.dart';

/// Use *.svg|icon|*.png assets
class CcCloseBtn extends StatelessWidget {
  final Color bgColor;
  final double? height, width;
  final Widget? icon;
  final String src;
  final VoidCallback onTap;

  const CcCloseBtn({
    super.key,
    this.bgColor = Colors.transparent,
    this.height,
    this.icon,
    required this.onTap,
    this.src = '',
    this.width,
  });

  @override
  Widget build(BuildContext context) =>
      CcInkWell(onTap: onTap, child: buildSizedBox(context));

  Widget buildContainer(BuildContext context) => Container(
    alignment: Alignment.center,
    height: context.respIconSize(baseSize: 20.0),
    width: context.respIconSize(baseSize: 20.0),
    color: bgColor,
    child: buildIcon(),
  );

  Widget buildIcon() =>
      icon ??
      (CcImageHelper.isSvg(src) ? SvgPicture.asset(src) : Image.asset(src));

  Widget buildSizedBox(BuildContext context) => Center(
    child: SizedBox(
      width: width ?? context.respIconSize(baseSize: 35.0),
      height: height ?? context.respIconSize(baseSize: 35.0),
      child: buildContainer(context),
    ),
  );
}
