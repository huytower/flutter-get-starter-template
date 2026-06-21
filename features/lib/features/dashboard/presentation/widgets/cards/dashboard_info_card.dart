import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class DashboardInfoCard extends StatelessWidget {
  final String title;
  final String description;

  const DashboardInfoCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return CcCard(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            title,
            textStyle: context.ccTextTheme.headlineMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: context.ccColorScheme.primary,
            ),
          ),
          const CcSpaceSM(),
          CcText(
            description,
            textStyle: context.ccTextTheme.bodyLarge?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
            maxLines: 5,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}
