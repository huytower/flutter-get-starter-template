import 'package:flutter/material.dart';

import '../../core/extensions/common/cc_responsive_extension.dart';
import '../padding/cc_padding.dart';

/// App logo ui,
/// show in splash presentation
class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({
    Key? key,
    this.isImageResId = true,
    required this.resId,
    this.padding = 34,
    this.width = 81,
  }) : super(key: key);

  final bool isImageResId;
  final double padding, width;
  final String resId;

  @override
  Widget build(BuildContext context) => CcPadding(
    isImageResId
        ? Image.asset(
            resId,
            width: width,
            height: width,
            errorBuilder: (_, a, b) => Icon(
              Icons.account_balance, // Fallback icon instead of missing asset
              size: context.respIconSize(baseSize: width),
            ),
          )
        : const SizedBox(),
    padding,
    padding,
    padding,
    padding,
  );
}
