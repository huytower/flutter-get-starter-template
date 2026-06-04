import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';
import '../../core/helper/cc_widget_helper.dart';
import '../icon/cc_icon.dart';
import '../inkwell/cc_inkwell.dart';
import '../padding/cc_padding.dart';

class CcBackBtn extends StatelessWidget {
  const CcBackBtn({super.key, required this.onPress, required this.icon});

  final VoidCallback onPress;
  final IconData icon;

  @override
  Widget build(BuildContext context) => CcPadding(
    Stack(
      children: [
        CcIcon(
          icon: icon,
          size: context.respIconSize(baseSize: 20.0),
          align: Alignment.center,
          color: Colors.white,
        ),
        CcInkWell(
          onTap: onPress,
          borderRadius: CcWidgetHelper.getCircleBorderRadius(),
        ),
      ],
    ),
    4,
    4,
    4,
    4,
  );
}

/// use *.svg only
class CcBackAssetBtn extends StatelessWidget {
  const CcBackAssetBtn(
    this.assetRes, {
    super.key,
    this.onTap,
    this.aspectRatio = 16 / 9,
  });

  final VoidCallback? onTap;
  final String assetRes;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) => CcInkWell(
    onTap: onTap ?? () => Get.back(),
    borderRadius: CcWidgetHelper.getCircleBorderRadius(),
    child: SizedBox(
      height: 45.0,
      width: 45.0,
      child: Center(
        child: SvgPicture.asset(assetRes, height: 22.0, width: 22.0),
      ),
    ),
  );
}

class CcBackDividerBtn extends StatelessWidget {
  static const double heightBack = 5, widthBack = 36, paddingBack = 14;

  const CcBackDividerBtn({super.key, required this.onPress});

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) => Positioned(
    left: Get.width / 2 - widthBack / 2,
    top: paddingBack,
    child: Stack(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(bottom: paddingBack),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ), // Assuming small rounded
            ),
            child: SizedBox(width: widthBack, height: heightBack),
          ),
        ),
        CcInkWell(
          onTap: onPress,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: const SizedBox(width: widthBack, height: heightBack),
        ),
      ],
    ),
  );
}
