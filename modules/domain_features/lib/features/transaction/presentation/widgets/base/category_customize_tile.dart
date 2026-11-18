import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

/// Trailing "Customize categories" cell of the category grid.
///
/// Uses the same filled, muted look as the add cell on the budget list so it
/// reads as an action rather than as one more selectable category.
class CategoryCustomizeTile extends StatelessWidget {
  const CategoryCustomizeTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final foreground = scheme.onSurfaceVariant.withValues(alpha: 0.6);

    return CcInteractBtnWrapper(
      onTap: onTap,
      isBouncing: true,
      useDebounce: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: context.brLg,
          border: Border.all(
            color: scheme.onSurface.withValues(alpha: 0.06),
            width: context.respDim(1.2),
          ),
        ),
        child: CcPadding(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: foreground,
                size: context.respIconSize(baseSize: 20),
              ),
              const CcSpaceXS(),
              CcText(
                el.tr(CcLocaleKeys.budget_customize_category),
                textAlign: TextAlign.center,
                align: Alignment.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          CcPaddingParams.DESC_XS, // bottom
          CcPaddingParams.SECTION_XS, // left
          CcPaddingParams.SECTION_XS, // right
          CcPaddingParams.DESC_XS, // top
        ),
      ),
    );
  }
}
