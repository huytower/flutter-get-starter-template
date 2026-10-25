import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as el;


class RatingPill extends StatelessWidget {
  const RatingPill({required this.averageRating, required this.onTap});

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
              CcText(
                el.tr(
                  CcLocaleKeys.profile_out_of_5,
                  namedArgs: {'rating': averageRating.toStringAsFixed(1)},
                ),
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
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

