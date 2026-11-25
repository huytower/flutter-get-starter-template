import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Card displaying an individual budget insight or warning banner.
class BudgetInsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const BudgetInsightCard({
    super.key,
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
                child: CustomPaint(painter: CcGridPatternPainter(color: color)),
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
