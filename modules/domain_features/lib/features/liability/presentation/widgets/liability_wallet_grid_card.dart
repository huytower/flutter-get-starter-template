import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/helper/budget_name_helper.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';

/// Compact 2-column grid card for a liability / lending item.
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
    final rawRepaid = liability.principalAmount - balance.outstandingBalance;
    final repaid = rawRepaid < 0 ? 0 : rawRepaid;

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
            textStyle: context.ccTextTheme.headlineMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
              fontSize: context.respDim(30),
            ),
          ),
          const SizedBox(height: 2),
          CcText(
            liability.isBorrow
                ? el.tr(CcLocaleKeys.liability_remaining_balance)
                : 'Cần thu',
            align: Alignment.center,
            textAlign: TextAlign.center,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant.withOpacity(0.75),
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
              TextSpan(text: liability.isBorrow ? 'Đã trả: ' : 'Đã nhận: '),
              TextSpan(
                text: TransactionFormHelpers.formatShortWithSymbol(
                  repaid,
                  currencyCode: liability.currencyCode,
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
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
          'assets/icon/${liability.isBorrow ? 'ic_borrow.webp' : 'ic_lend.webp'}',
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
              TextSpan(text: liability.isBorrow ? 'Đi vay: ' : 'Tổng mượn: '),
              TextSpan(
                text: TransactionFormHelpers.formatShortWithSymbol(
                  liability.principalAmount,
                  currencyCode: liability.currencyCode,
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
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
