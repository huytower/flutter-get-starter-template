import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/budget_name_helper.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';

/// Compact 2-column grid card for a liability (borrowing) item.
class LiabilityWalletGridCard extends StatelessWidget {
  final LiabilityBalanceEntity balance;
  final bool isEditMode;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LiabilityWalletGridCard({
    super.key,
    required this.balance,
    this.isEditMode = false,
    this.canDelete = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final liability = balance.liability;
    final repaid = balance.effectiveRepaidAmount;

    Get.log(
      '[LiabilityWalletGridCard] "${liability.categoryLabel}": '
      'principal=${liability.principalAmount}, outstanding=${balance.outstandingBalance}, repaid=$repaid',
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildMainCard(context, liability, repaid),
        if (isEditMode) ..._buildEditBadges(context),
      ],
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    LiabilityEntity liability,
    int repaid,
  ) {
    final scheme = context.ccColorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(context.respDim(12)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: context.brLg,
        border: context.borderSubtle,
        gradient: context.surfaceGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeader(context, liability),
          _buildRemainingSection(context, liability),
          CcDividerLine(color: scheme.onSurface.withOpacity(0.08)),
          _buildRepaidRow(context, liability, repaid),
          _buildPrincipalRow(context, liability),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LiabilityEntity liability) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Container(
          width: context.respDim(28),
          height: context.respDim(28),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CcIconToken(
              iconDataFromCode(
                liability.categoryIconCode ?? 0,
                fontFamily: liability.categoryIconFamily,
              ),
              size: context.respIconSize(baseSize: 14),
              color: scheme.primary,
            ),
          ),
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            BudgetNameHelper.getDisplayName(
              name: liability.categoryLabel,
              categoryNameKey: liability.categoryNameKey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textStyle: context.ccTextTheme.labelLarge?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingSection(
    BuildContext context,
    LiabilityEntity liability,
  ) {
    final scheme = context.ccColorScheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CcText(
            TransactionFormHelpers.formatShortWithSymbol(
              balance.outstandingBalance.abs(),
              currencyCode: liability.currencyCode,
            ),
            align: Alignment.center,
            textAlign: TextAlign.center,
            textStyle: context.ccTextTheme.headlineLarge?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
            ),
          ),
          const CcSpaceXS(),
          CcText(
            el.tr(CcLocaleKeys.liability_remaining_balance),
            align: Alignment.center,
            textAlign: TextAlign.center,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant.withOpacity(0.75),
              fontWeight: CcTypographyParams.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepaidRow(
    BuildContext context,
    LiabilityEntity liability,
    int repaid,
  ) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Image.asset(
          'assets/icon/ic_repay.webp',
          color: scheme.primary,
          width: context.respIconSize(baseSize: 18),
          height: context.respIconSize(baseSize: 18),
        ),
        const CcSpaceXS(),
        RichText(
          text: TextSpan(
            style: context.ccTextTheme.labelSmall?.copyWith(
              color: scheme.onSurface,
            ),
            children: [
              TextSpan(text: el.tr(CcLocaleKeys.liability_repaid_prefix)),
              TextSpan(
                text: TransactionFormHelpers.formatShortWithSymbol(
                  repaid,
                  currencyCode: liability.currencyCode,
                ),
                style: context.ccTextTheme.labelSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: CcTypographyParams.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrincipalRow(BuildContext context, LiabilityEntity liability) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Image.asset(
          'assets/icon/ic_borrow.webp',
          color: scheme.primary,
          width: context.respIconSize(baseSize: 18),
          height: context.respIconSize(baseSize: 18),
        ),
        const CcSpaceXS(),
        RichText(
          text: TextSpan(
            style: context.ccTextTheme.labelSmall?.copyWith(
              color: scheme.onSurface,
            ),
            children: [
              TextSpan(text: el.tr(CcLocaleKeys.liability_borrow_prefix)),
              TextSpan(
                text: TransactionFormHelpers.formatShortWithSymbol(
                  liability.principalAmount,
                  currencyCode: liability.currencyCode,
                ),
                style: context.ccTextTheme.labelSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: CcTypographyParams.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEditBadges(BuildContext context) {
    final scheme = context.ccColorScheme;
    return [
      if (canDelete)
        Positioned(
          top: context.respDim(-4),
          left: context.respDim(-4),
          child: CcEditBadge(
            icon: Icons.remove,
            color: scheme.error,
            foregroundColor: scheme.onError,
            onTap: onDelete,
          ),
        ),
      Positioned(
        top: context.respDim(-4),
        right: context.respDim(-4),
        child: CcEditBadge(
          icon: Icons.edit,
          color: scheme.primary,
          foregroundColor: scheme.onPrimary,
          onTap: onEdit,
        ),
      ),
    ];
  }
}
