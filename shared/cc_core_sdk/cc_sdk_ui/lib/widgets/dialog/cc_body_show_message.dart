import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/config/tokens/cc_base_colors.dart';
import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../../widgets/button/cc_base_btn.dart';
import '../../widgets/space/cc_space.dart';

class CcBodyShowMessage extends StatelessWidget {
  final Widget child;
  final String title;
  final String content;
  final VoidCallback? onTabOK;
  final bool isExistOK;
  final String? cancelText;
  final String? okText;

  const CcBodyShowMessage({
    Key? key,
    required this.child,
    this.content = '',
    this.title = '',
    this.onTabOK,
    this.isExistOK = false,
    this.cancelText,
    this.okText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
    height: context.respIconSize(baseSize: 235.0),
    padding: EdgeInsets.symmetric(
      vertical: context.respPadding(25.0),
      horizontal: context.respPadding(25.0),
    ),
    child: Column(
      children: [
        const CcSpaceLG(),
        const CcSpaceLG(),
        title.isNotEmpty
            ? Container(
                margin: EdgeInsets.only(
                  bottom: context.respPadding(20.0),
                  top: context.respPadding(10.0),
                ),
                child: Text(title, style: context.ccTextTheme.headlineSmall),
              )
            : const SizedBox(),
        child,
        const CcSpaceLG(),
        const CcSpaceLG(),
        SizedBox(
          height: context.respIconSize(baseSize: 40.0),
          child: Row(
            children: [
              !isExistOK
                  ? Expanded(
                      child: CcBaseBtn.bouncing(
                        onTap: () => Get.back(),
                        textColor: CcBaseColors.white100,
                        title: cancelText ?? 'Cancel',
                        bgColor: [
                          context.ccColorScheme.primary,
                          context.ccColorScheme.primary,
                        ],
                      ),
                    )
                  : const SizedBox(),
              Expanded(
                child: CcBaseBtn.bouncing(
                  onTap: onTabOK,
                  textColor: CcBaseColors.white100,
                  title: okText ?? 'OK',
                  bgColor: [
                    context.ccColorScheme.primary,
                    context.ccColorScheme.primary,
                  ],
                ),
              ),
            ],
          ),
        ),
        const CcSpaceSM(),
      ],
    ),
  );
}
