import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/budget_name_helper.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';

/// Full-width card for a liability / lending item on list pages.
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
    final repaid = liability.principalAmount - balance.outstandingBalance;

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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.respDim(16)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: context.brLg,
        border: context.borderSubtle,
        gradient: context.surfaceGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, liability),
          const CcSpaceSM(),
          _buildRemainingSection(context, liability),
          const CcSpaceSM(),
          CcDividerLine(
            color: context.ccColorScheme.onSurface.withOpacity(0.08),
          ),
          const CcSpaceSM(),
          _buildRepaidRow(context, liability, repaid),
          const CcSpaceXS(),
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
          width: context.respDim(32),
          height: context.respDim(32),
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
              size: context.respIconSize(baseSize: 18),
              color: scheme.primary,
            ),
          ),
        ),
        const CcSpaceSM(),
        Expanded(
          child: CcText(
            BudgetNameHelper.getDisplayName(
              name: liability.categoryLabel,
              categoryNameKey: liability.categoryNameKey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textStyle: context.ccTextTheme.titleSmall?.copyWith(
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

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CcText(
            TransactionFormHelpers.formatShortWithSymbol(
              balance.outstandingBalance,
              currencyCode: liability.currencyCode,
            ),
            textStyle: context.ccTextTheme.headlineLarge?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
              fontSize: context.respDim(32),
            ),
          ),
          const CcSpaceXS(),
          CcText(
            el.tr(CcLocaleKeys.liability_remaining_balance),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant.withOpacity(0.7),
              fontWeight: FontWeight.w500,
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
          'assets/icon/${liability.isBorrow ? 'ic_repay.webp' : 'ic_collect.webp'}',
          color: scheme.primary,
          width: context.respIconSize(baseSize: 22),
          height: context.respIconSize(baseSize: 22),
        ),
        const CcSpaceSM(),
        CcText(
          liability.isBorrow
              ? '${el.tr(CcLocaleKeys.transaction_record_repay)}:'
              : '${el.tr(CcLocaleKeys.transaction_record_collect)}:',
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
          ),
        ),
        const CcSpaceXS(),
        CcText(
          TransactionFormHelpers.formatShortWithSymbol(
            repaid,
            currencyCode: liability.currencyCode,
          ),
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: scheme.onSurface,
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
          'assets/icon/${liability.isBorrow ? 'ic_borrow.webp' : 'ic_lend.webp'}',
          color: scheme.primary,
          width: context.respIconSize(baseSize: 22),
          height: context.respIconSize(baseSize: 22),
        ),
        const CcSpaceSM(),
        CcText(
          liability.isBorrow
              ? '${el.tr(CcLocaleKeys.liability_borrow)}:'
              : '${el.tr(CcLocaleKeys.liability_lend)}:',
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
          ),
        ),
        const CcSpaceXS(),
        CcText(
          TransactionFormHelpers.formatShortWithSymbol(
            liability.principalAmount,
            currencyCode: liability.currencyCode,
          ),
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: scheme.onSurface,
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
