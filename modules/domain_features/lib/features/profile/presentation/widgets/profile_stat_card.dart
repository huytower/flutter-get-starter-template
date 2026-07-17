import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLocked = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final dimColor = context.ccColorScheme.onSurfaceVariant.withOpacity(0.4);

    return Container(
      padding: const EdgeInsets.all(CcPaddingParams.SPACE_MD),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(CcCircularParams.CARD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CcIconToken(
            icon,
            size: 18,
            color: isLocked ? dimColor : context.ccColorScheme.primary,
          ),
          const CcSpaceXS(),
          CcText(
            label,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
          const CcSpaceXS(),
          CcText(
            value,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? context.ccColorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
