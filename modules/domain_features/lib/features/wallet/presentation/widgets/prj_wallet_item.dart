import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Individual wallet card item for horizontal strips.
/// Displays icon, name, and balance with glassy selection highlights.
///
/// This is a generic UI component that does not depend on any domain entities.
class PrjWalletItem extends StatelessWidget {
  final String name;
  final int iconCode;
  final bool hasSelected;
  final Color activeColor;
  final LinearGradient? defaultBackgroundColor;
  final VoidCallback onTap;
  final String balanceText;

  const PrjWalletItem({
    super.key,
    required this.name,
    required this.iconCode,
    required this.hasSelected,
    required this.activeColor,
    this.defaultBackgroundColor,
    required this.onTap,
    required this.balanceText,
  });

  @override
  Widget build(BuildContext context) {
    return CcInteractionWrapper(
      onTap: onTap,
      useDebounce: true,
      hasBouncing: true,
      hasEnable: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (hasSelected)
            Positioned.fill(
              child: CcGlassyGradientBackground(
                centerColor: activeColor.withAlpha(10),
                endColor: activeColor.withAlpha(20),
              ),
            ),
          _buildMainCard(context),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    final scheme = context.ccColorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: defaultBackgroundColor ?? context.primaryVerticalGradient,
        borderRadius: context.brMd,
        border: Border.all(
          color: hasSelected
              ? activeColor.withAlpha(10)
              : scheme.onSurface.withAlpha(5),
          width: context.respDim(1),
        ),
      ),
      child: CcPadding(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryIcon(context),
            const CcSpaceSM(),
            _buildDesc(context),
          ],
        ),
        4,
        6,
        16,
        4,
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(35),
      height: context.respDim(35),
      decoration: BoxDecoration(
        color: hasSelected
            ? activeColor.withAlpha(10)
            : scheme.onSurface.withAlpha(5),
        borderRadius: context.brMd,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasSelected)
            Positioned.fill(
              child: CcGlassyGradientIcon(
                centerColor: activeColor.withAlpha(20),
                endColor: activeColor.withAlpha(40),
              ),
            ),
          CcIconToken(
            color: hasSelected ? activeColor : scheme.onSurfaceVariant,
            iconDataFromCode(iconCode),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildDesc(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CcText(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: hasSelected ? activeColor : scheme.onSurfaceVariant,
          ),
        ),
        CcText(
          balanceText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: hasSelected ? activeColor : scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
