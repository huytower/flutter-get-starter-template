import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_base_colors.dart';

/// Floating action button component for common FAB usage.
/// Provides customizable icon, color, and behavior.
class CcFloatingActionButton extends StatelessWidget {
  const CcFloatingActionButton({
    Key? key,
    required this.onTap,
    this.icon,
    this.iconData,
    this.backgroundColor = CcBaseColors.neutral70,
    this.foregroundColor = Colors.white,
    this.heroTag,
    this.mini = false,
    this.elevation = 6.0,
    this.tooltip,
    this.showing = true,
  }) : super(key: key);

  final VoidCallback onTap;
  final Widget? icon;
  final IconData? iconData;
  final Color backgroundColor;
  final Color foregroundColor;
  final String? heroTag;
  final bool mini;
  final double elevation;
  final String? tooltip;
  final bool showing;

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? Icon(iconData ?? Icons.add);

    if (!showing) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      heroTag: heroTag ?? 'fab_${DateTime.now().millisecondsSinceEpoch}',
      onPressed: onTap,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      mini: mini,
      elevation: elevation,
      tooltip: tooltip,
      child: effectiveIcon,
    );
  }
}
