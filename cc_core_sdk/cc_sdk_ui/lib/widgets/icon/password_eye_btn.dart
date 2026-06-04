import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/helper/cc_widget_helper.dart';
import '../inkwell/cc_inkwell.dart';

/// Use *.svg icon only
class PasswordEyeButtonWidget extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  final double? aspectRatio;

  const PasswordEyeButtonWidget(
    this.icon, {
    super.key,
    this.onTap,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Center(child: SvgPicture.asset(icon)),
      if (onTap != null)
        CcInkWell(
          onTap: onTap!,
          borderRadius: CcWidgetHelper.getCircleBorderRadius(),
        ),
    ],
  );
}
