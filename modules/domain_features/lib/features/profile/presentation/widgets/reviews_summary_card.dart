import 'dart:io' show Platform;

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'reviews/rating_pill.dart';

/// Customer reviews summary card with overall score, star ratings breakdown,
/// and direct store rating deep-link support.
class ReviewsSummaryCard extends StatelessWidget {
  const ReviewsSummaryCard({
    super.key,
    required this.averageRating,
    required this.totalRatings,
    required this.breakdown,
    this.iosAppId,
    this.androidPackageName,
    this.title,
    this.onCalculateInfoTap,
    this.onRateTap,
  });

  /// e.g. 4.7
  final double averageRating;

  /// e.g. 40
  final int totalRatings;

  /// Star level (5..1) -> percentage (0..100). Order is not required;
  /// rows are always rendered 5 -> 1.
  final Map<int, num> breakdown;

  /// Numeric iOS App Store id, used to deep link straight to the
  /// "write a review" flow. Optional if this app has no iOS build yet.
  final String? iosAppId;

  /// Android package name (applicationId), used for the Play Store
  /// in-store rating deep link. Optional if this app has no Android build yet.
  final String? androidPackageName;

  final String? title;

  /// Called when the "How do we calculate ratings?" link is tapped.
  final VoidCallback? onCalculateInfoTap;

  /// Overrides the default store-deep-link behavior when the rating pill
  /// is tapped. Leave null to use the built-in platform store launcher.
  final VoidCallback? onRateTap;

  Future<void> _openStoreForRating() async {
    try {
      if (!kIsWeb && Platform.isIOS && iosAppId != null) {
        final uri = Uri.parse(
          'itms-apps://itunes.apple.com/app/id$iosAppId?action=write-review',
        );
        final fallback = Uri.parse(
          'https://apps.apple.com/app/id$iosAppId?action=write-review',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          await launchUrl(fallback, mode: LaunchMode.externalApplication);
        }
        return;
      }

      if (!kIsWeb && Platform.isAndroid && androidPackageName != null) {
        final uri = Uri.parse('market://details?id=$androidPackageName');
        final fallback = Uri.parse(
          'https://play.google.com/store/apps/details?id=$androidPackageName',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          await launchUrl(fallback, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      'Store rating deep link failed: $e'.Log();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.PAGE_XS),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.primary.withAlpha(50),
        boxShadow: [
          BoxShadow(
            color: context.ccColorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTotalRatings(context),
          const CcSpaceXS(),
          _buildRatingPill(context),
          const CcSpaceSM(),
          if (onCalculateInfoTap != null) ...[
            const CcSpaceLG(),
            _buildCalculateInfoLink(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return CcText(
      title ?? el.tr(CcLocaleKeys.profile_customer_reviews),
      align: Alignment.center,
      textAlign: TextAlign.center,
      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: context.ccColorScheme.onSurface,
      ),
    );
  }

  Widget _buildRatingPill(BuildContext context) {
    return Center(
      child: RatingPill(
        averageRating: averageRating,
        onTap: onRateTap ?? _openStoreForRating,
      ),
    );
  }

  Widget _buildTotalRatings(BuildContext context) {
    return CcText(
      el.tr(
        CcLocaleKeys.profile_customer_ratings_count,
        namedArgs: {'count': '$totalRatings'},
      ),
      align: Alignment.center,
      textAlign: TextAlign.center,
      textStyle: context.ccTextTheme.bodyMedium?.copyWith(
        color: context.ccColorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildCalculateInfoLink(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onCalculateInfoTap,
        borderRadius: context.brSm,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(8),
            vertical: context.respPadding(4),
          ),
          child: CcText(
            el.tr(CcLocaleKeys.profile_calculate_ratings_info),
            textAlign: TextAlign.center,
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
