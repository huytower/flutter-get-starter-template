import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/category_entity.dart';

class CategoryUiUtils {
  CategoryUiUtils._();

  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required CategoryEntity category,
    String? title,
    String? content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: CcText(
          title ?? el.tr(CcLocaleKeys.common_delete),
          textStyle: context.ccTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: CcText(
          content ??
              '${el.tr(CcLocaleKeys.common_delete)} "${el.tr(category.nameKey)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: CcText(
              el.tr(CcLocaleKeys.common_cancel),
              textStyle: context.ccTextTheme.labelLarge,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: CcText(
              el.tr(CcLocaleKeys.common_delete),
              textStyle: context.ccTextTheme.labelLarge?.copyWith(
                color: context.ccColorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
