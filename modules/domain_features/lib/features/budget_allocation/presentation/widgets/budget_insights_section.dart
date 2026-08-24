import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/money_format_helper.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../get_x/budget_allocation_controller.dart';

/// Phase 3.4 "AI Actions" panel — pacing/penalty/deficit/anomaly warnings.
/// Applied design pattern: Toast-style banners with grid background.
class BudgetInsightsSection extends StatelessWidget {
  final BudgetAllocationController controller;

  const BudgetInsightsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final insights = controller.insights.value;
      if (insights == null || !insights.hasAnything) return const SizedBox();

      return CcSymmetricPadding(
        horizontal: CcPaddingParams.PAGE_SM,
        vertical: CcPaddingParams.SPACE_XS,
        child: Column(
          children: [
            if (insights.isDeficit)
              _InsightCard(
                title: el.tr(CcLocaleKeys.budget_insights_title),
                description: el.tr(
                  CcLocaleKeys.budget_deficit_warning,
                  namedArgs: {
                    'amount': formatVndWithSymbol(insights.deficitAmount),
                  },
                ),
                icon: Icons.error_outline_rounded,
                color: context.ccColorScheme.error,
                onTap: () => context.router.push(const ReportRoute()),
              ),
            for (final warning in insights.penaltyWarnings)
              _InsightCard(
                title: warning.budgetName,
                description: el.tr(
                  CcLocaleKeys.budget_penalty_warning,
                  namedArgs: {
                    'name': warning.budgetName,
                    'percent': '${warning.percentUsed}',
                  },
                ),
                icon: Icons.warning_amber_rounded,
                color: context.ccColorScheme.error,
                onTap: () => context.router.push(const ReportRoute()),
              ),
            for (final warning in insights.pacingWarnings)
              _InsightCard(
                title: warning.budgetName,
                description: el.tr(
                  CcLocaleKeys.budget_pacing_hint,
                  namedArgs: {
                    'name': warning.budgetName,
                    'days': '${warning.daysRemaining}',
                    'amount': formatVndWithSymbol(warning.suggestedDailySpend),
                  },
                ),
                icon: Icons.info_outline_rounded,
                color: PrjColors.info,
                onTap: () => context.router.push(const ReportRoute()),
              ),
            if (insights.anomalyCount > 0)
              _InsightCard(
                title: el.tr(CcLocaleKeys.budget_insights_title),
                description: el.tr(
                  CcLocaleKeys.budget_anomaly_hint,
                  namedArgs: {'count': '${insights.anomalyCount}'},
                ),
                icon: Icons.auto_awesome_outlined,
                color: PrjColors.info,
                onTap: () => context.router.push(const ReportRoute()),
              ),
          ],
        ),
      );
    });
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _InsightCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: context.respDim(12)),
      child: CcBouncing(
        onTap: onTap,
        borderRadius: context.brLg,
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: context.brLg,
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: context.respDim(80),
                child: CustomPaint(painter: _GridPatternPainter(color: color)),
              ),
              Padding(
                padding: EdgeInsets.all(context.respDim(16)),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.respDim(8)),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: context.respIconSize(baseSize: 20),
                      ),
                    ),
                    const CcSpaceMD(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CcText(
                            title,
                            textStyle: context.ccTextTheme.titleSmall?.copyWith(
                              fontWeight: CcTypographyParams.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          const CcSpaceXS(),
                          CcText(
                            description,
                            maxLines: 2,
                            textStyle: context.ccTextTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  final Color color;

  _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final double squareSize = size.height / 6;
    final int rows = 6;
    final int cols = 5;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Create a pattern similar to the one in the image:
        // A grid where squares have very low, varying opacities
        final bool shouldPaint = (r + c) % 2 == 0;
        if (!shouldPaint) continue;

        final double opacity = ((r * c) % 3 == 0) ? 0.04 : 0.015;

        paint.color = color.withOpacity(opacity);
        canvas.drawRect(
          Rect.fromLTWH(
            size.width - (c + 1) * squareSize,
            r * squareSize,
            squareSize - 2, // 2px gap between squares
            squareSize - 2,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
