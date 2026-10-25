import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;

import 'package:flutter/material.dart';

class RatingBarRow extends StatelessWidget {
  const RatingBarRow({
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
          child: CcText(
            el.tr(
              CcLocaleKeys.profile_star_count,
              namedArgs: {'count': '$level'},
            ),
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
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
          child: CcText(
            '%',
            textAlign: TextAlign.right,
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
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
