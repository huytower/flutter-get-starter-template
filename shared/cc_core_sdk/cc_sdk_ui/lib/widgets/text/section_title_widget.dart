import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_padding_params.dart';
import '../../core/config/tokens/cc_typography_params.dart';
import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';
import '../space/cc_space.dart';

class SectionTitleWidget extends StatelessWidget {
  const SectionTitleWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => title.isNotEmpty
      ? Container(
          width: MediaQuery.sizeOf(context).width,
          height: context.respPadding(CcPaddingParams.SECTION_SM),
          margin: EdgeInsets.only(
            left: context.respPadding(CcPaddingParams.SECTION_SM),
            right: context.respPadding(CcPaddingParams.SECTION_SM),
            top: context.respPadding(CcPaddingParams.SECTION_SM),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: context.ccColorScheme.onSurface,
                fontSize: context.respFontSize(20.0),
                fontWeight: CcTypographyParams.semiBold,
              ),
              text: title,
            ),
            maxLines: 1,
            textAlign: TextAlign.start,
          ),
        )
      : const CcSpaceXL();
}
