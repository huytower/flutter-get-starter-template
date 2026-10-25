import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'review_feedback_section.dart';
import 'reviews_summary_card.dart';

class AppRatingSheetContent extends StatefulWidget {
  const AppRatingSheetContent({super.key});

  @override
  State<AppRatingSheetContent> createState() => _AppRatingSheetContentState();
}

class _AppRatingSheetContentState extends State<AppRatingSheetContent> {
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;

    // Allow sheet height to adapt dynamically when soft keyboard is up
    final maxHeight = bottomInset > 0
        ? (screenHeight - bottomInset) * 0.90
        : screenHeight * 0.65;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: SafeArea(
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
                    mediaQuery.padding.bottom +
                    context.respPadding(CcPaddingParams.SPACE_MD),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReviewsSummaryCard(
                    averageRating: _selectedRating.toDouble(),
                    totalRatings: 10,
                    breakdown: const {5: 100, 4: 0, 3: 0, 2: 0, 1: 0},
                    iosAppId: '6738361005',
                    androidPackageName: 'vn.sosachxin.finance',
                    onRatingSelected: (rating) {
                      setState(() => _selectedRating = rating);
                    },
                  ),
                  ReviewFeedbackSection(
                    averageRating: _selectedRating.toDouble(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
