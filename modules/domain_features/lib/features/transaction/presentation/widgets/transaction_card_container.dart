import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class TransactionCardContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TransactionCardContainer({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CcInkWell(
      onTap: onTap ?? () {},
      borderRadius: CcWidgetHelper.getBorderRoundedLG(),
      child: Container(
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
        child: child,
      ),
    );
  }
}
