import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:flutter/material.dart';

class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.onLongPress,
    this.trailingLabel,
    this.trailingWidget,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
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
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(16),
          vertical: context.respDim(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: context.respIconSize(baseSize: 20),
              color: context.ccColorScheme.primary,
            ),
            SizedBox(width: context.respDim(12)),
            Expanded(
              child: CcText(
                label,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.ccColorScheme.onSurface,
                ),
              ),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else ...[
              if (trailingLabel != null) ...[
                CcText(
                  trailingLabel!,
                  textStyle: context.ccTextTheme.bodySmall?.copyWith(
                    color: context.ccColorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: context.respIconSize(baseSize: 20),
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
