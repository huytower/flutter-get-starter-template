import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Interactive rating pill that allows the user to tap 1..5 stars to select a rating.
class RatingPill extends StatefulWidget {
  const RatingPill({
    super.key,
    required this.averageRating,
    this.initialRating,
    this.onRatingSelected,
  });

  final double averageRating;
  final int? initialRating;
  final ValueChanged<int>? onRatingSelected;

  @override
  State<RatingPill> createState() => _RatingPillState();
}

class _RatingPillState extends State<RatingPill> {
  late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating =
        widget.initialRating ?? widget.averageRating.round().clamp(1, 5);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.ccColorScheme.surfaceContainerHighest,
      borderRadius: context.brPill,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(16),
          vertical: context.respPadding(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++) ...[
              CcIconButton.bouncing(
                onTap: () {
                  setState(() => _selectedRating = i);
                  widget.onRatingSelected?.call(i);
                },
                icon: Icon(
                  i <= _selectedRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: context.ccColorScheme.primary,
                  size: context.respDim(24),
                ),
                width: context.respDim(28),
                height: context.respDim(28),
              ),
              if (i != 5) const CcSpaceXS(),
            ],
            const CcSpaceSM(),
            CcText(
              el.tr(
                CcLocaleKeys.profile_out_of_5,
                namedArgs: {'rating': '$_selectedRating.0'},
              ),
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                fontWeight: CcTypographyParams.bold,
                color: context.ccColorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
