import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_padding_params.dart';
import '../../core/config/tokens/cc_typography_params.dart';
import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../padding/cc_padding.dart';
import '../text/cc_text.dart';

class SkipBtn extends StatelessWidget {
  const SkipBtn({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CcPadding(
    GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: context.respIconSize(baseSize: 103.0),
        height: context.respIconSize(baseSize: 76.0),
        child: Center(
          child: CcText(
            el.tr(CcLocaleKeys.common_skip),
            color: context.ccColorScheme.onSurfaceVariant,
            fontSize: CcTypographyParams.bodyLarge,
            fontWeight: CcTypographyParams.medium,
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
  );
}
