import 'package:flutter/material.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';

import 'reviews_summary_card.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ReviewsSummaryCard(
          averageRating: 5.0,
          totalRatings: 10,
          breakdown: {5: 100, 4: 0, 3: 0, 2: 0, 1: 0},
          iosAppId: '6738361005',
          androidPackageName: 'vn.sosachxin.finance',
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }
}
