import 'dart:io' show Platform;

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
        final uri = Uri.parse(
          'market://details?id=com.google.android.apps.bard',
        );
        // final uri = Uri.parse('market://details?id=$androidPackageName');
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
    final sortedLevels = breakdown.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 5 -> 1

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(24),
        context.respPadding(28),
        context.respPadding(24),
        context.respPadding(24),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: context.brXl,
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
          _buildTitle(context),
          const CcSpaceXL(),
          _buildRatingPill(context),
          const CcSpaceSM(),
          _buildTotalRatings(context),
          const CcSpaceXL(),
          _buildBreakdown(context, sortedLevels),
          if (onCalculateInfoTap != null) ...[
            const CcSpaceLG(),
            _buildCalculateInfoLink(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title ?? el.tr(CcLocaleKeys.profile_customer_reviews),
      textAlign: TextAlign.center,
      style: context.ccTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: context.ccColorScheme.onSurface,
      ),
    );
  }

  Widget _buildRatingPill(BuildContext context) {
    return Center(
      child: _RatingPill(
        averageRating: averageRating,
        onTap: onRateTap ?? _openStoreForRating,
      ),
    );
  }

  Widget _buildTotalRatings(BuildContext context) {
    return Text(
      el.tr(
        CcLocaleKeys.profile_customer_ratings_count,
        namedArgs: {'count': '$totalRatings'},
      ),
      textAlign: TextAlign.center,
      style: context.ccTextTheme.bodyMedium?.copyWith(
        color: context.ccColorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildBreakdown(BuildContext context, List<int> sortedLevels) {
    return Column(
      children: [
        for (var i = 0; i < sortedLevels.length; i++) ...[
          _RatingBarRow(
            level: sortedLevels[i],
            percent: breakdown[sortedLevels[i]]!.toDouble(),
            delay: Duration(milliseconds: 80 * i),
          ),
          if (i != sortedLevels.length - 1) const CcSpaceMD(),
        ],
      ],
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
          child: Text(
            el.tr(CcLocaleKeys.profile_calculate_ratings_info),
            textAlign: TextAlign.center,
            style: context.ccTextTheme.bodySmall?.copyWith(
              color: context.ccColorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.averageRating, required this.onTap});

  final double averageRating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fullStars = averageRating.floor();
    final hasHalfStar = averageRating - fullStars >= 0.5;

    return Material(
      color: context.ccColorScheme.surfaceContainerHighest,
      borderRadius: context.brPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.brPill,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(20),
            vertical: context.respPadding(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 5; i++) ...[
                Icon(
                  i < fullStars
                      ? Icons.star_rounded
                      : (i == fullStars && hasHalfStar)
                      ? Icons.star_half_rounded
                      : Icons.star_border_rounded,
                  color: context.ccColorScheme.primary,
                  size: context.respDim(22),
                ),
                if (i != 4) const CcSpaceXS(),
              ],
              const CcSpaceSM(),
              Text(
                el.tr(
                  CcLocaleKeys.profile_out_of_5,
                  namedArgs: {'rating': averageRating.toStringAsFixed(1)},
                ),
                style: context.ccTextTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.ccColorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingBarRow extends StatelessWidget {
  const _RatingBarRow({
    required this.level,
    required this.percent,
    required this.delay,
  });

  final int level;
  final double percent;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: context.respDim(56),
          child: Text(
            el.tr(
              CcLocaleKeys.profile_star_count,
              namedArgs: {'count': '$level'},
            ),
            style: context.ccTextTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.ccColorScheme.primary,
            ),
          ),
        ),
        const CcSpaceMD(),
        Expanded(
          child: ClipRRect(
            borderRadius: context.brPill,
            child: Container(
              height: context.respDim(8),
              color: context.ccColorScheme.surfaceContainer,
              alignment: Alignment.centerLeft,
              child: _DelayedFill(
                targetFraction: (percent.clamp(0, 100)) / 100,
                delay: delay,
              ),
            ),
          ),
        ),
        const CcSpaceMD(),
        SizedBox(
          width: context.respDim(42),
          child: Text(
            '${percent.round()}%',
            textAlign: TextAlign.right,
            style: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _DelayedFill extends StatefulWidget {
  const _DelayedFill({required this.targetFraction, required this.delay});

  final double targetFraction;
  final Duration delay;

  @override
  State<_DelayedFill> createState() => _DelayedFillState();
}

class _DelayedFillState extends State<_DelayedFill> {
  double _fraction = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _fraction = widget.targetFraction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          width: constraints.maxWidth * _fraction,
          height: context.respDim(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.ccColorScheme.primaryContainer,
                context.ccColorScheme.primary,
              ],
            ),
          ),
        );
      },
    );
  }
}
