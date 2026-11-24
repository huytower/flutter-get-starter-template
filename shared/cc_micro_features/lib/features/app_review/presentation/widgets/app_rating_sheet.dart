import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../app_review_options.dart';
import 'review_feedback_section.dart';
import 'reviews_summary_card.dart';

/// "Rate the app" bottom sheet: stars and a store link ([ReviewsSummaryCard])
/// above the feedback form ([ReviewFeedbackSection]). It grows when the
/// keyboard opens so the text field stays visible.
///
/// ```dart
/// AppRatingSheet.show(context, feedbackReporter: reporter, options: options);
/// ```
class AppRatingSheet extends StatefulWidget {
  const AppRatingSheet({
    super.key,
    required this.feedbackReporter,
    required this.options,
  });

  final CcFeedbackReporter feedbackReporter;
  final AppReviewOptions options;

  static Future<void> show(
    BuildContext context, {
    required CcFeedbackReporter feedbackReporter,
    required AppReviewOptions options,
  }) {
    return CcAdaptiveBottomSheet.show<void>(
      context: context,
      backgroundColor: null,
      builder: (_) =>
          AppRatingSheet(feedbackReporter: feedbackReporter, options: options),
    );
  }

  @override
  State<AppRatingSheet> createState() => _AppRatingSheetState();
}

class _AppRatingSheetState extends State<AppRatingSheet> {
  int _selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    // Taller while the keyboard is up, so the text field stays visible.
    final maxHeight = bottomInset > 0
        ? (screenHeight - bottomInset) * 0.90
        : screenHeight * 0.65;
    final options = widget.options;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Material(
            color: context.ccColorScheme.surface,
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
                    totalRatings: options.totalRatings,
                    iosAppId: options.iosAppId,
                    androidPackageName: options.androidPackageName,
                    onRatingSelected: (rating) =>
                        setState(() => _selectedRating = rating),
                  ),
                  ReviewFeedbackSection(
                    feedbackReporter: widget.feedbackReporter,
                    praiseOptions: options.praiseOptions,
                    criticismOptions: options.criticismOptions,
                    rating: _selectedRating.toDouble(),
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
