import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide iconDataFromCode;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../../core/presentation/helper/wallet_icon_helper.dart';
import '../../models/unified_category_item.dart';

class UnifiedCategoryItemWidget extends StatelessWidget {
  const UnifiedCategoryItemWidget({
    super.key,
    required this.item,
    required this.hasSelected,
    required this.activeColor,
    required this.onTap,
  });

  final UnifiedCategoryItem item;
  final bool hasSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcInteractionWrapper(
      onTap: onTap,
      hasBouncing: true,
      useDebounce: false,
      child: Stack(
        clipBehavior: Clip.none,
        // The grid cell decides the card size.
        fit: StackFit.expand,
        children: [
          if (hasSelected) _buildActiveBackground(context),
          _buildItemContainer(context, scheme),
          if (item.hasBudget) _buildBudgetIndicator(context, scheme),
        ],
      ),
    );
  }

  Widget _buildActiveBackground(BuildContext context) {
    return Positioned.fill(
      child: CcGlassyGradientBackground(
        centerColor: activeColor.withValues(alpha: 0.04),
        endColor: activeColor.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _buildItemContainer(BuildContext context, ColorScheme scheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: hasSelected
            ? activeColor.withValues(alpha: 0.02)
            : scheme.onSurface.withValues(alpha: 0.02),
        borderRadius: context.brLg,
        border: Border.all(
          color: hasSelected
              ? activeColor.withValues(alpha: 0.04)
              : scheme.onSurface.withValues(alpha: 0.02),
          width: context.respDim(1),
        ),
      ),
      child: CcPadding(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(context),
            const CcSpaceXS(),
            _buildLabel(context, scheme),
          ],
        ),
        CcPaddingParams.DESC_XS, // bottom
        CcPaddingParams.SECTION_XS, // left
        CcPaddingParams.SECTION_XS, // right
        CcPaddingParams.DESC_XS, // top
      ),
    );
  }

  Widget _buildLabel(BuildContext context, ColorScheme scheme) {
    return CcText(
      item.customName ?? el.tr(item.nameKey ?? ''),
      textAlign: TextAlign.center,
      align: Alignment.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textStyle: context.ccTextTheme.labelSmall?.copyWith(
        fontWeight: hasSelected ? FontWeight.bold : FontWeight.normal,
        color: hasSelected ? activeColor : scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildBudgetIndicator(BuildContext context, ColorScheme scheme) {
    return Positioned(
      top: context.respDim(6),
      right: context.respDim(6),
      child: Icon(
        Icons.bar_chart,
        size: context.respIconSize(baseSize: 14),
        color: hasSelected
            ? activeColor.withAlpha(50)
            : scheme.onSurfaceVariant.withAlpha(50),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(35),
      height: context.respDim(35),
      decoration: BoxDecoration(
        color: hasSelected
            ? activeColor.withValues(alpha: 0.04)
            : scheme.onSurface.withValues(alpha: 0.02),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasSelected)
            Positioned.fill(
              child: CcGlassyGradientIcon(
                centerColor: activeColor.withValues(alpha: 0.08),
                endColor: activeColor.withValues(alpha: 0.16),
              ),
            ),
          CcIcon(
            icon: iconDataFromCode(item.iconCode, fontFamily: item.iconFamily),
            size: context.respIconSize(baseSize: 18),
            color: hasSelected ? activeColor : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
