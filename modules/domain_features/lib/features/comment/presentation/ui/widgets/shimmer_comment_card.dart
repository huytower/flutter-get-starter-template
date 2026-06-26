import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class ShimmerCommentCard extends StatelessWidget {
  const ShimmerCommentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.respDim(160),
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_XS),
        vertical: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: CcWidgetHelper.getBorderRoundedLG(),
        boxShadow: CcWidgetHelper.getBoxShadows(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcShimmer(
            width: double.infinity,
            height: context.respPadding(20),
            borderRadius: BorderRadius.circular(
              context.respPadding(CcPaddingParams.SPACE_XS),
            ),
          ),
          const CcSpaceSM(),
          CcShimmer(
            width: context.respPadding(200),
            height: context.respPadding(14),
            borderRadius: BorderRadius.circular(
              context.respPadding(CcPaddingParams.SPACE_XS),
            ),
          ),
          const CcSpaceSM(),
          CcShimmer(
            width: double.infinity,
            height: context.respPadding(14),
            borderRadius: BorderRadius.circular(
              context.respPadding(CcPaddingParams.SPACE_XS),
            ),
          ),
          const CcSpaceXS(),
          CcShimmer(
            width: double.infinity,
            height: context.respPadding(14),
            borderRadius: BorderRadius.circular(
              context.respPadding(CcPaddingParams.SPACE_XS),
            ),
          ),
        ],
      ),
    );
  }
}
