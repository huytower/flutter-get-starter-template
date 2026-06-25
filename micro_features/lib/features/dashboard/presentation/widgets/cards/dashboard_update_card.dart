import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../core/extensions/date_time_extension.dart';

class DashboardUpdateCard extends StatelessWidget {
  final DateTime lastUpdated;

  const DashboardUpdateCard({super.key, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return CcCard(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            el.tr(CcLocaleKeys.dashboard_last_updated),
            textStyle: context.ccTextTheme.titleLarge,
          ),
          const CcSpaceSM(),
          CcText(
            lastUpdated.toDashboardRelativeFormat(),
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
