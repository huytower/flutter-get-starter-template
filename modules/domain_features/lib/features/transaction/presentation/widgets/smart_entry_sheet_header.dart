import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class SmartEntrySheetHeader extends StatelessWidget {
  const SmartEntrySheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primaryContainer],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.respDim(16)),
          topRight: Radius.circular(context.respDim(16)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CcText(
                  title,
                  textStyle: context.ccTextTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: CcTypographyParams.bold,
                  ),
                ),
                if (subtitle != null)
                  CcText(
                    subtitle,
                    textStyle: context.ccTextTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
