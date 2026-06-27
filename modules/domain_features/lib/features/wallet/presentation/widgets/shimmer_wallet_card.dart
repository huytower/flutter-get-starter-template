import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class ShimmerWalletCard extends StatelessWidget {
  const ShimmerWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.respDim(140),
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
          Row(
            children: [
              CcShimmer(
                width: context.respPadding(48),
                height: context.respPadding(48),
                borderRadius: BorderRadius.circular(
                  context.respPadding(CcPaddingParams.SPACE_SM),
                ),
              ),
              const CcSpaceMD(),
              Expanded(
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
                    const CcSpaceXS(),
                    CcShimmer(
                      width: context.respPadding(120),
                      height: context.respPadding(16),
                      borderRadius: BorderRadius.circular(
                        context.respPadding(CcPaddingParams.SPACE_XS),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
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
