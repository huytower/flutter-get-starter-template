import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

// Purpose:
// small reusable widgets for loading states and empty API responses
// intended as part of the shared UI library
class NoDataResponseWidget extends StatelessWidget {
  const NoDataResponseWidget({Key? key, this.onRefresh}) : super(key: key);

  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.folder_open,
          size: context.respIconSize(baseSize: 48.0),
          color: Colors.grey,
        ),
        const CcSpaceSM(),
        CcText(
          el.tr(CcLocaleKeys.common_no_data),
          color: Colors.grey,
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
              el.tr(CcLocaleKeys.app_error_retry),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    ),
  );
}
