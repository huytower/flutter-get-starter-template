import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/adaptive_bottom_sheet.dart';
import 'app_rating_sheet_content.dart';

class AppRatingSheet extends StatelessWidget {
  const AppRatingSheet({super.key, required this.feedbackReporter});

  final CcFeedbackReporter feedbackReporter;

  static Future<void> show(
    BuildContext context,
    CcFeedbackReporter feedbackReporter,
  ) {
    return showAdaptiveBottomSheet<void>(
      context: context,
      backgroundColor: null,
      builder: (_) => AppRatingSheetContent(feedbackReporter: feedbackReporter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppRatingSheetContent(feedbackReporter: feedbackReporter);
  }
}
