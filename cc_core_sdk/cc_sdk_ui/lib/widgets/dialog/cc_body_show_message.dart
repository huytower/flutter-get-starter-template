import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/cc_locale_keys.dart';

import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../../widgets/button/cc_debounce_widget.dart';
import '../../widgets/space/cc_space.dart';

class CcBodyShowMessage extends StatelessWidget {
  final Widget child;
  final String title;
  final String content;
  final VoidCallback? onTabOK;
  final bool isExistOK;

  const CcBodyShowMessage({
    Key? key,
    required this.child,
    this.content = '',
    this.title = '',
    this.onTabOK,
    this.isExistOK = false,
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
                      child: CcDebounce(
                        onTap: () => Get.back(),
                        iconColor: Colors.pink,
                        textColor: Colors.white,
                        title: el.tr(CcLocaleKeys.common_cancel),
                      ),
                    )
                  : const SizedBox(),
              Expanded(
                child: CcDebounce(
                  onTap: onTabOK,
                  iconColor: Colors.pink,
                  textColor: Colors.white,
                  title: el.tr(CcLocaleKeys.common_ok),
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
