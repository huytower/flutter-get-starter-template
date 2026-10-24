import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'reviews_summary_card.dart';
import 'review_feedback_section.dart';

class AppRatingSheet extends StatelessWidget {
  const AppRatingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AppRatingSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.80;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Material(
          color: scheme.surface,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.respDim(28)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.paddingOf(context).bottom +
                  context.respPadding(CcPaddingParams.SPACE_MD),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReviewsSummaryCard(
                  averageRating: 5.0,
                  totalRatings: 10,
                  breakdown: {5: 100, 4: 0, 3: 0, 2: 0, 1: 0},
                  iosAppId: '6738361005',
                  androidPackageName: 'vn.sosachxin.finance',
                ),
                ReviewFeedbackSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
