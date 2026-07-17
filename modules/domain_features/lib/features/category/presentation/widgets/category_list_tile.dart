import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/icon_utils.dart';
import '../../domain/entities/category_entity.dart';

class CategoryListTile extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Widget? trailing;

  const CategoryListTile({
    super.key,
    required this.category,
    required this.onTap,
    this.onDelete,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(context.respDim(14)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
          vertical: context.respDim(4),
        ),
        leading: Container(
          width: context.respDim(40),
          height: context.respDim(40),
          decoration: BoxDecoration(
            color: (category.color ?? scheme.primary).withOpacity(0.12),
            borderRadius: BorderRadius.circular(context.respDim(12)),
          ),
          child: CcIconToken(
            iconDataFromCode(
              category.iconCode,
              fontFamily: category.iconFamily,
            ),
            size: 20,
            color: category.color ?? scheme.primary,
          ),
        ),
        title: CcText(
          el.tr(category.nameKey),
          textStyle: context.ccTextTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing:
            trailing ??
            (onDelete != null
                ? CcIconButton.bouncing(
                    icon: Icon(
                      Icons.delete_outline,
                      color: scheme.error,
                      size: context.respIconSize(baseSize: 24),
                    ),
                    onTap: onDelete!,
                  )
                : null),
      ),
    );
  }
}
