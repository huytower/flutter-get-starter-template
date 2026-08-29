import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';

/// One row in [LiabilityBalanceList] — a loan's counterparty/category, direction
/// and status badges, and remaining-vs-principal balance.
class LiabilityListCard extends StatelessWidget {
  final LiabilityBalanceEntity balance;
  final VoidCallback? onTap;

  const LiabilityListCard({super.key, required this.balance, this.onTap});

  @override
  Widget build(BuildContext context) {
    final liability = balance.liability;
    final directionColor = liability.isBorrow
        ? PrjColors.warning
        : context.ccColorScheme.secondary;

    return CcBouncing(
      onTap: onTap ?? () {},
      child: CcSymmetricPadding(
        horizontal: CcPaddingParams.SPACE_LG,
        vertical: CcPaddingParams.SPACE_MD,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                context.respPadding(CcPaddingParams.SPACE_SM),
              ),
              decoration: BoxDecoration(
                color: directionColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icon/ic_remain.webp',
                width: context.respIconSize(baseSize: 22),
                height: context.respIconSize(baseSize: 22),
              ),
            ),
            const CcSpaceMD(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CcText(
                    '${TransactionFormHelpers.formatAmount(balance.outstandingBalance.toString())} đ',
                    textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: balance.isSettled
                          ? context.ccColorScheme.onSurfaceVariant
                          : context.ccColorScheme.onSurface,
                    ),
                  ),
                  CcText(
                    el.tr(CcLocaleKeys.liability_remaining_balance),
                    textStyle: context.ccTextTheme.labelSmall?.copyWith(
                      color: context.ccColorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
