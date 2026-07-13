import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

// Purpose:
// small reusable widgets for loading states and empty API responses
// intended as part of the shared UI library
class NoDataResponseWidget extends StatelessWidget {
  const NoDataResponseWidget({
    Key? key,
    this.onRefresh,
    this.message,
    this.refreshText,
  }) : super(key: key);

  final Future<void> Function()? onRefresh;
  final String? message;
  final String? refreshText;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.folder_open,
          size: context.respIconSize(baseSize: 48.0),
          color: context.ccColorScheme.onSurfaceVariant,
        ),
        const CcSpaceSM(),
        CcText(
          message ?? 'No data found',
          color: context.ccColorScheme.onSurfaceVariant,
          textAlign: TextAlign.center,
          align: Alignment.center,
        ),
        if (onRefresh != null) ...[
          const CcSpaceLG(),
          ElevatedButton(
            onPressed: onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: CcBaseColors.brand500,
            ),
            child: CcText(
              refreshText ?? 'Retry',
              color: context.ccColorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    ),
  );
}
