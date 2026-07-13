import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'transaction_card_container.dart';

class ShimmerTransactionCard extends StatelessWidget {
  const ShimmerTransactionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return TransactionCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcShimmer(
                width: context.respPadding(100),
                height: context.respPadding(20),
                borderRadius: BorderRadius.circular(
                  context.respPadding(CcPaddingParams.SPACE_XS),
                ),
              ),
              CcShimmer(
                width: context.respPadding(60),
                height: context.respPadding(20),
                borderRadius: BorderRadius.circular(context.respDim(4)),
              ),
            ],
          ),
          const CcSpaceSM(),
          CcShimmer(
            width: double.infinity,
            height: context.respPadding(24),
            borderRadius: BorderRadius.circular(
              context.respPadding(CcPaddingParams.SPACE_XS),
            ),
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
