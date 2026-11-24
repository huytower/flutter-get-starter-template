import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Rating header of the review sheet: the "N customer ratings" line, a
/// [CcRatingPill] and a store button (top right) that opens the app's store
/// page to write a review.
class ReviewsSummaryCard extends StatelessWidget {
  const ReviewsSummaryCard({
    super.key,
    required this.averageRating,
    required this.totalRatings,
    this.iosAppId,
    this.androidPackageName,
    this.onCalculateInfoTap,
    this.onRateTap,
    this.onRatingSelected,
    this.onStoreTap,
  });

  /// Starting value of the stars, e.g. 4.7.
  final double averageRating;

  /// Shown as "N customer ratings".
  final int totalRatings;

  /// Numeric App Store id, for the iOS "write a review" deep link.
  final String? iosAppId;

  /// Android application id, for the Play Store page.
  final String? androidPackageName;

  /// Shows a "How do we calculate ratings?" link when set.
  final VoidCallback? onCalculateInfoTap;

  /// Called after any star is tapped.
  final VoidCallback? onRateTap;

  /// Called with the tapped star (1–5).
  final ValueChanged<int>? onRatingSelected;

  /// Replaces the default store deep link of the top-right button.
  final VoidCallback? onStoreTap;

  Future<void> _openStoreForRating() async {
    if (kIsWeb) return;
    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS when iosAppId != null:
          await _launch(
            Uri.parse(
              'itms-apps://itunes.apple.com/app/id$iosAppId?action=write-review',
            ),
            Uri.parse(
              'https://apps.apple.com/app/id$iosAppId?action=write-review',
            ),
          );
        case TargetPlatform.android when androidPackageName != null:
          await _launch(
            Uri.parse('market://details?id=$androidPackageName'),
            Uri.parse(
              'https://play.google.com/store/apps/details?id=$androidPackageName',
            ),
          );
        default:
          break;
      }
    } catch (error) {
      'Store rating deep link failed: $error'.Log('ReviewsSummaryCard');
    }
  }

  Future<void> _launch(Uri storeUri, Uri webFallback) async {
    if (await canLaunchUrl(storeUri)) {
      await launchUrl(storeUri);
    } else {
      await launchUrl(webFallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        vertical: context.respPadding(CcPaddingParams.PAGE_XS),
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withAlpha(50),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTotalRatings(context),
              const CcSpaceXS(),
              _buildRatingPill(),
              const CcSpaceSM(),
              if (onCalculateInfoTap != null) ...[
                const CcSpaceLG(),
                _buildCalculateInfoLink(context),
              ],
            ],
          ),
          Positioned(top: 0, right: 0, child: _buildStoreButton(context)),
        ],
      ),
    );
  }

  Widget _buildStoreButton(BuildContext context) {
    return CcIconButton.bouncing(
      onTap: onStoreTap ?? _openStoreForRating,
      tooltip: el.tr(CcMfLocaleKeys.app_review_rate_app),
      icon: Icon(
        Icons.storefront_rounded,
        color: context.ccColorScheme.primary,
        size: context.respIconSize(baseSize: 22),
      ),
      width: context.respDim(32),
      height: context.respDim(32),
    );
  }

  Widget _buildRatingPill() {
    return Center(
      child: CcRatingPill(
        averageRating: averageRating,
        ratingLabel: (rating) => el.tr(
          CcMfLocaleKeys.app_review_out_of_5,
          namedArgs: {'rating': '$rating.0'},
        ),
        onRatingSelected: (rating) {
          onRatingSelected?.call(rating);
          onRateTap?.call();
        },
      ),
    );
  }

  Widget _buildTotalRatings(BuildContext context) {
    return CcText(
      el.tr(
        CcMfLocaleKeys.app_review_customer_ratings_count,
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
            el.tr(CcMfLocaleKeys.app_review_calculate_ratings_info),
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
