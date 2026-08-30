import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../liability/domain/entities/liability_balance_entity.dart';
import '../get_x/budget_allocation_controller.dart';
import 'liability_wallet_preview_card.dart';

/// Content card for the Lend (Collect) section on the dashboard.
class LendWalletsCard extends StatelessWidget {
  const LendWalletsCard({
    required this.balances,
    required this.onAdd,
    required this.onSeeAll,
    required this.isFront,
    super.key,
  });

  final List<LiabilityBalanceEntity> balances;
  final VoidCallback onAdd;
  final VoidCallback onSeeAll;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetAllocationController>();
    final scheme = context.ccColorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: context.brXl,
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withOpacity(isFront ? 0.08 : 0.03),
            blurRadius: context.respDim(20),
            offset: Offset(0, context.respDim(10)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, scheme, controller),
          if (balances.isEmpty)
            _buildEmptyState(context)
          else
            _buildHorizontalList(context),
          const CcSpaceSM(),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme scheme,
    BudgetAllocationController controller,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_MD),
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      child: Row(
        children: [
          Icon(
            Icons.handshake_outlined,
            size: context.respIconSize(baseSize: 18),
            color: scheme.primary,
          ),
          const CcSpaceXS(),
          Expanded(
            child: CcText(
              el.tr(CcLocaleKeys.liability_lend),
              textStyle: context.ccTextTheme.titleSmall?.copyWith(
                fontWeight: CcTypographyParams.bold,
              ),
            ),
          ),
          if (isFront) ...[
            CcIconButton.bouncing(
              onTap: onAdd,
              icon: Icon(
                Icons.add_circle_outline_rounded,
                size: context.respIconSize(baseSize: 20),
                color: scheme.primary,
              ),
            ),
            const CcSpaceXS(),
            CcIconButton.bouncing(
              onTap: controller.toggleLiabilityCardStack,
              icon: Icon(
                Icons.swap_vert_rounded,
                size: context.respIconSize(baseSize: 20),
                color: scheme.onSurfaceVariant.withOpacity(0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: CcText(
        el.tr(CcLocaleKeys.liability_empty_state),
        textStyle: context.ccTextTheme.bodySmall?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
    return HorizontalFadeScrollView(
      height: context.respDim(85),
      builder: (scrollController) => ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
        ),
        itemCount: balances.length,
        itemBuilder: (context, index) {
          final balance = balances[index];
          return Padding(
            padding: EdgeInsets.only(right: context.respDim(12)),
            child: LiabilityWalletPreviewCard(
              balance: balance,
              onTap: onSeeAll,
            ),
          );
        },
      ),
    );
  }
}
