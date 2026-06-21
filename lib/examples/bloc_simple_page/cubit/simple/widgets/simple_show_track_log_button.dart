import 'package:cc_sdk_ui/core/extensions/cc_context_extension.dart';
import 'package:cc_sdk_ui/core/helper/cc_dialog_helper.dart';
import 'package:cc_sdk_ui/widgets/button/cc_base_btn.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:features/features/crash_log/export_crash_log.dart';
import 'package:flutter/material.dart';
import 'package:message/cc_locale_keys.dart';

/// Button to show track log modal
class SimpleShowTrackLogButton extends StatelessWidget {
  const SimpleShowTrackLogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CcBaseBtn(
      onTap: () {
        CcDialogHelper.showModalBottomSheet(
          context,
          const CrashLogViewerPage(),
        );
      },
      title: el.tr(CcLocaleKeys.common_ok),
      bgColor: [context.ccColorScheme.primary],
      textColor: context.ccColorScheme.onPrimary,
      height: 48,
      width: double.infinity,
    );
  }
}
