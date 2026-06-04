import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../padding/cc_padding.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    this.onTapBack,
    this.onTapAtRightButton,
    this.iconBackAssetRes,
    this.iconPageAssetRes,
    this.isBackButtonVisible = true,
    required this.title,
  });

  final VoidCallback? onTapBack, onTapAtRightButton;

  final String? iconBackAssetRes, iconPageAssetRes;

  final bool isBackButtonVisible;

  final String title;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      /// icon page (ex. : News logo, ...)
      getIconPageWidget(context),

      /// header body
      Row(
        children: [
          const CcSpaceLG(),
          Expanded(
            child: SizedBox(
              height: context.respIconSize(baseSize: 76.0),
              child: Row(
                children: [
                  /// Space left
                  SizedBox(width: context.respPadding(12.0)),

                  /// Back button
                  Opacity(
                    opacity: isBackButtonVisible ? 1.0 : 0.0,
                    child: (onTapBack != null && iconBackAssetRes != null)
                        ? CcBackAssetBtn(iconBackAssetRes!, onTap: onTapBack!)
                        : const SizedBox(width: 48),
                  ),

                  /// Title
                  Expanded(child: getTitlePageWidget(context)),
                ],
              ),
            ),
          ),

          /// Right side: Skip button
          getRightButtonWidget(context),

          /// Space right
          SizedBox(width: context.respPadding(15.0)),
        ],
      ),
    ],
  );

  Widget getRightButtonWidget(BuildContext context) =>
      onTapAtRightButton != null
      ? CcPadding(
          GestureDetector(
            onTap: onTapAtRightButton!,
            behavior: HitTestBehavior.translucent,
            child: SizedBox(
              width: context.respIconSize(baseSize: 103.0),
              height: context.respIconSize(baseSize: 76.0),
              child: Center(
                child: CcText(
                  'Bỏ qua',
                  color: context.ccColorScheme.onSurfaceVariant,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                  align: Alignment.center,
                ),
              ),
            ),
          ),
          0,
          context.respPadding(CcPaddingParams.PAGE_LG),
          0,
          0,
        )
      : const SizedBox();

  Widget getIconPageWidget(BuildContext context) => CcPositionBottom(
    bottom: getSpaceBottom(context),
    child: iconPageAssetRes != null
        ? getImageResWidget(iconPageAssetRes!)
        : const SizedBox(),
  );

  Widget getImageResWidget(String iconPageAssetRes) =>
      CcImageHelper.isSvg(iconPageAssetRes)
      ? SvgPicture.asset(iconPageAssetRes)
      : Image.asset(iconPageAssetRes, height: 35, fit: BoxFit.contain);

  double getSpaceBottom(BuildContext context) {
    return context.respPadding(12.0);
  }

  Widget getTitlePageWidget(BuildContext context) => CcText(
    title,
    fontSize: 24.0,
    align: Alignment.center,
    textAlign: TextAlign.center,
    fontWeight: FontWeight.w500,
  );
}
