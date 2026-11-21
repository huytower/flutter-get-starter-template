import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/transaction/presentation/widgets/base/category_customize_tile.dart';
import 'package:domain_features/features/transaction/presentation/widgets/base/category_selection_layout.dart';
import 'package:flutter/material.dart';

/// Empty state of an asset row (investment / liability / lend forms): the
/// "Customize" cell on the left with the "nothing here yet" [hint] beside it.
///
/// Shown only while the row has no items — once there is at least one, the
/// row lists the items alone.
class CategoryCustomizeEmptyState extends StatelessWidget {
  const CategoryCustomizeEmptyState({
    super.key,
    required this.hint,
    required this.onCustomize,
  });

  final String hint;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.respDim(100),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_XS),
          vertical: context.respDim(4),
        ),
        child: Row(
          children: [
            SizedBox(
              width: context.respDim(categoryItemWidth),
              child: CategoryCustomizeTile(onTap: onCustomize),
            ),
            const CcSpaceSM(),
            Expanded(
              child: CcText(
                hint,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
                  fontStyle: FontStyle.italic,
                ),
                align: Alignment.center,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
