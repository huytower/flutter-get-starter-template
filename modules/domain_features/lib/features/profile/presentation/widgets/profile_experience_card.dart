import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../user_level/domain/entities/user_level_status_entity.dart';

class ProfileExperienceCard extends StatelessWidget {
  final int level;
  final UserLevelStatusEntity levelStatus;
  final VoidCallback? onTap;
  final bool isImmersive;

  const ProfileExperienceCard({
    super.key,
    required this.level,
    required this.levelStatus,
    this.onTap,
    this.isImmersive = false,
  });

  @override
  Widget build(BuildContext context) {
    return CcBouncing(
      onTap: onTap,
      borderRadius: context.brLg,
      child: Container(
        width: double.infinity,
        decoration: isImmersive
            ? null
            : BoxDecoration(
                color: context.ccColorScheme.surface,
                borderRadius: context.brLg,
                boxShadow: [
                  BoxShadow(
                    color: context.ccColorScheme.onSurface.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
        child: ClipRRect(
          borderRadius: context.brLg,
          child: Stack(
            children: [_buildBackgroundWave(context), _buildContent(context)],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundWave(BuildContext context) {
    return Positioned(
      top: context.respDim(-5),
      right: context.respDim(-10),
      child: Opacity(
        opacity: 0.4,
        child: SizedBox(
          width: context.respDim(120),
          height: context.respDim(80),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 10,
              minY: 0,
              maxY: 10,
              titlesData: const FlTitlesData(show: false),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  curveSmoothness: 0.5,
                  color: context.ccColorScheme.primary,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.ccColorScheme.primary.withOpacity(0.2),
                        context.ccColorScheme.primary.withOpacity(0),
                      ],
                    ),
                  ),
                  spots: const [
                    FlSpot(0, 4),
                    FlSpot(1, 7),
                    FlSpot(2, 3),
                    FlSpot(3, 8),
                    FlSpot(4, 5),
                    FlSpot(5, 6),
                    FlSpot(6, 4),
                    FlSpot(7, 9),
                    FlSpot(8, 2),
                    FlSpot(9, 5),
                    FlSpot(10, 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CcText(
            el.tr(CcLocaleKeys.profile_experience_level_progress),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.ccColorScheme.onSurface,
            ),
          ),
          Column(
            children: [
              CcText(
                el.tr(
                  CcLocaleKeys.profile_level_title,
                  namedArgs: {'level': '$level', 'title': _getLevelTitle()},
                ),
                textStyle: context.ccTextTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.ccColorScheme.primary,
                ),
              ),
              const CcSpaceXS(),
              _buildProgressBar(context),
            ],
          ),
          CcText(
            el.tr(CcLocaleKeys.profile_tap_to_return),
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final double progress;
    final String progressText;

    if (level < 2) {
      // LV1 -> LV2: 6 guideline tasks + 2 reconciliations = 8 steps
      final streak = levelStatus.reconciliationStreak.clamp(0, 2);
      final completed = levelStatus.completedGuidelineCount + streak;
      progress = completed / 8.0;

      'ProfileExperienceCard LV1 Debug:\n'
              '   Guideline Count: ${levelStatus.completedGuidelineCount}\n'
              '   Streak: $streak\n'
              '   Total Completed: $completed\n'
              '   Progress: $progress'
          .Log('ProfileExperienceCard');

      progressText = el.tr(
        CcLocaleKeys.profile_progress_steps,
        namedArgs: {'completed': '$completed', 'total': '8'},
      );
    } else {
      // LV2 -> LV3: streak based
      progress =
          levelStatus.reconciliationStreak /
          UserLevelStatusEntity.lv3RequiredStreak;

      progressText = el.tr(
        CcLocaleKeys.profile_streak_weeks,
        namedArgs: {'count': '${levelStatus.reconciliationStreak}'},
      );
    }

    return Column(
      children: [
        Container(
          height: context.respDim(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.ccColorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutBack,
            tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
            builder: (context, value, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.ccColorScheme.primary,
                        context.ccColorScheme.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      if (value > 0)
                        BoxShadow(
                          color: context.ccColorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const CcSpaceXS(),
        CcText(
          progressText,
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getLevelTitle() {
    if (level >= 3) return el.tr(CcLocaleKeys.profile_level_master);
    if (level >= 2) return el.tr(CcLocaleKeys.profile_level_intermediate);
    return el.tr(CcLocaleKeys.profile_level_novice);
  }
}
