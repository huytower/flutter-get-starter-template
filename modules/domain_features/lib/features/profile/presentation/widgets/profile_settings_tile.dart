import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailingLabel,
    this.trailingWidget,
    this.showChevron = true,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? trailingLabel;
  final Widget? trailingWidget;
  final bool showChevron;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: onTap,
      child: CcSymmetricPadding(
        horizontal: CcPaddingParams.SPACE_LG,
        vertical: CcPaddingParams.SPACE_LG,
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(context.respDim(10)),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.08),
                    borderRadius: context.brMd,
                  ),
                  child: CcIconToken(icon, size: 22),
                ),
                if (badge != null)
                  Positioned(top: -4, right: -4, child: badge!),
              ],
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
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const CcSpaceXS(),
                    CcText(
                      subtitle!,
                      textStyle: context.ccTextTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant.withAlpha(70),
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
                const CcSpaceXS(),
                CcText(
                  trailingLabel!,
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: context.respIconSize(baseSize: 20),
                  color: scheme.outline.withAlpha(50),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
