import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class ProfileLevelBadge extends StatelessWidget {
  const ProfileLevelBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CcBaseColors.white15,
        borderRadius: BorderRadius.circular(CcCircularParams.RADIUS_MAX),
        border: Border.all(color: CcBaseColors.white40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          CcText(
            label,
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
