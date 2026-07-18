import 'package:flutter/material.dart';

import 'package:cc_bridge/export_cc_bridge.dart';

class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    this.trailingLabel,
    this.trailingWidget,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? trailingLabel;
  final Widget? trailingWidget;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: CcSymmetricPadding(
        horizontal: CcPaddingParams.SPACE_LG,
        vertical: CcPaddingParams.SPACE_LG,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.respDim(10)),
              decoration: BoxDecoration(
                color: context.ccColorScheme.primary.withOpacity(0.08),
                borderRadius: context.brMd,
              ),
              child: CcIconToken(icon, size: 22),
            ),
            const CcSpaceLG(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CcText(
                    label,
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.ccColorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const CcSpaceXS(),
                    CcText(
                      subtitle!,
                      textStyle: context.ccTextTheme.bodySmall?.copyWith(
                        color: context.ccColorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else ...[
              if (trailingLabel != null) ...[
                CcText(
                  trailingLabel!,
                  textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                    color: context.ccColorScheme.onSurfaceVariant,
                  ),
                ),
                const CcSpaceXS(),
              ],
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: context.respIconSize(baseSize: 20),
                  color: context.ccColorScheme.outline,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
