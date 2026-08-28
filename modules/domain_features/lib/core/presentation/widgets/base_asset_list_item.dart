import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'edit_badge.dart';

class BaseAssetListItem extends StatelessWidget {
  final Widget header;
  final List<Widget> stats;
  final bool isEditMode;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Widget? dragHandle;

  const BaseAssetListItem({
    super.key,
    required this.header,
    required this.stats,
    this.isEditMode = false,
    this.canDelete = true,
    required this.onEdit,
    required this.onDelete,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: context.respPadding(CcPaddingParams.SPACE_MD),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CcGlassyGradientBackground()),
          Container(
            padding: EdgeInsets.all(context.respDim(12)),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: context.brLg,
              border: Border.all(
                color: scheme.onSurface.withOpacity(0.08),
                width: context.respDim(1),
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.onSurface.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const CcSpaceMD(),
                Column(children: stats),
              ],
            ),
          ),
          if (isEditMode) ..._buildEditBadges(context),
        ],
      ),
    );
  }

  List<Widget> _buildEditBadges(BuildContext context) {
    final scheme = context.ccColorScheme;
    return [
      if (canDelete)
        Positioned(
          top: context.respDim(-6),
          left: context.respDim(-6),
          child: EditBadge(
            icon: Icons.remove,
            color: scheme.error,
            foregroundColor: scheme.onError,
            onTap: onDelete,
          ),
        ),
      Positioned(
        top: context.respDim(-6),
        right: context.respDim(-6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dragHandle != null) ...[dragHandle!, const CcSpaceXS()],
            EditBadge(
              icon: Icons.edit,
              color: scheme.primary,
              foregroundColor: scheme.onPrimary,
              onTap: onEdit,
            ),
          ],
        ),
      ),
    ];
  }
}
