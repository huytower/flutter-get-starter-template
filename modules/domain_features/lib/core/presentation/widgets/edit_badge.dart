import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class EditBadge extends StatelessWidget {
  const EditBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.foregroundColor,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return CcInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.respDim(12)),
      child: Container(
        width: context.respDim(24),
        height: context.respDim(24),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.surface, width: 1.5),
          boxShadow: [
            BoxShadow(color: scheme.shadow.withOpacity(0.3), blurRadius: 4),
          ],
        ),
        child: Icon(
          icon,
          color: foregroundColor,
          size: context.respIconSize(baseSize: 14),
        ),
      ),
    );
  }
}
