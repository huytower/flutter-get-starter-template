import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/prj_locale_keys.dart';

/// Button to show track log modal
class SimpleShowTrackLogButton extends StatelessWidget {
  const SimpleShowTrackLogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CcBaseButton(
      onTap: () {
        CcDialogHelper.showModalBottomSheet(
          context,
          const CrashLogViewerPage(),
        );
      },
      title: el.tr(PrjLocaleKeys.common_ok),
      backgroundColor: [context.ccColorScheme.primary],
      textColor: context.ccColorScheme.onPrimary,
      height: 48,
      width: double.infinity,
    );
  }
}
