import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

// Purpose:
// small reusable widgets for loading states and empty API responses
// intended as part of the shared UI library
class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key, this.message}) : super(key: key);

  /// Optional override for the empty-state message.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: context.respIconSize(baseSize: 56.0),
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const CcSpaceSM(),
            CcText(
              message ?? 'No data found',
              color: scheme.onSurfaceVariant,
              textAlign: TextAlign.center,
              align: Alignment.center,
            ),
          ],
        ),
      ),
    );
  }
}
