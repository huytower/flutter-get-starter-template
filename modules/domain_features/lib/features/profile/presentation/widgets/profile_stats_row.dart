import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class ProfileStatsRow extends StatelessWidget {
  final int daysToSunday;

  const ProfileStatsRow({super.key, required this.daysToSunday});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          context.respDim(CcCircularParams.CARD),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          context.respDim(CcCircularParams.CARD),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildStatCell(
                  context,
                  icon: Icons.access_time_rounded,
                  label: el.tr(CcLocaleKeys.profile_weekly_audit),
                  value: el.tr(
                    CcLocaleKeys.profile_days_left,
                    namedArgs: {'count': '$daysToSunday'},
                  ),
                  valueColor: context.ccColorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildStatCell(
                  context,
                  icon: Icons.lock_rounded,
                  label: el.tr(CcLocaleKeys.profile_debt_loan),
                  value: el.tr(
                    CcLocaleKeys.profile_unlock_at_lv,
                    namedArgs: {'level': '3'},
                  ),
                  valueColor: context.ccColorScheme.onSurfaceVariant
                      .withOpacity(0.5),
                  isLocked: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isLocked = false,
  }) {
    final iconColor = isLocked
        ? context.ccColorScheme.onSurfaceVariant.withOpacity(0.5)
        : context.ccColorScheme.primary;
    return Padding(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: context.respIconSize(baseSize: 18),
              color: iconColor,
            ),
          ),
          const CcSpaceXS(),
          CcText(
            label,
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
            align: Alignment.center,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.respDim(2)),
          CcText(
            value,
            textStyle: context.ccTextTheme.titleSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
            align: Alignment.center,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
