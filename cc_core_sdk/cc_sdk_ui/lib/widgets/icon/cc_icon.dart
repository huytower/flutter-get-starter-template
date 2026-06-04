import 'package:flutter/material.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';
import '../../core/helper/cc_widget_helper.dart';
import '../inkwell/cc_inkwell.dart';
import '../padding/cc_padding.dart';

class CcIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final Alignment? align;

  const CcIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.align,
  });

  @override
  Widget build(BuildContext context) => Align(
    alignment: align ?? Alignment.center,
    child: CcPadding(
      Icon(
        icon,
        size: size ?? context.respIconSize(baseSize: 20.0),
        color: color ?? Colors.black,
      ),
      8,
      8,
      8,
      8,
    ),
  );
}

class CcMediaIcon extends StatelessWidget {
  final bool isVisible;
  final Color color;
  final IconData icon;
  final double? iconSize;
  final VoidCallback? onTap;

  const CcMediaIcon({
    super.key,
    this.onTap,
    required this.isVisible,
    required this.icon,
    this.iconSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      isVisible
          ? CcIcon(
              icon: icon,
              size: iconSize ?? context.respIconSize(baseSize: 20.0),
              color: color,
              align: Alignment.center,
            )
          : const SizedBox(width: 35),
      if (onTap != null)
        CcInkWell(
          onTap: onTap!,
          borderRadius: CcWidgetHelper.getCircleBorderRadius(),
        ),
    ],
  );
}
