import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';
import 'cards/dashboard_counter_card.dart';
import 'cards/dashboard_info_card.dart';
import 'cards/dashboard_update_card.dart';

/// Dashboard Content Widget - Presentation Layer
class DashboardContent extends StatelessWidget {
  final dynamic dashboardData;
  final bool isRefreshing;
  final bool isUpdating;

  const DashboardContent({
    Key? key,
    required this.dashboardData,
    this.isRefreshing = false,
    this.isUpdating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CcResponsiveContainer(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_LG),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CcResponsiveFlex(
                  spacing: CcPaddingParams.SPACE_LG,
                  tabletColumns: 2,
                  desktopColumns: 3,
                  children: [
                    DashboardInfoCard(
                      title: dashboardData.title,
                      description: dashboardData.description,
                    ),
                    DashboardCounterCard(itemCount: dashboardData.itemCount),
                    DashboardUpdateCard(lastUpdated: dashboardData.lastUpdated),
                  ],
                ),
              ),
              const CcSpaceLG(),
              _buildRefreshButton(context),
            ],
          ),
        ),
        if (isRefreshing)
          const Positioned(
            top: CcPaddingParams.SPACE_LG,
            right: CcPaddingParams.SPACE_LG,
            child: CcLoadingIconWidget(),
          ),
        if (isUpdating)
          const Positioned.fill(child: Center(child: CcLoadingIconWidget())),
      ],
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return CcBaseBtn(
      onTap: () {
        context.read<DashboardBloc>().add(
          const RefreshDashboardDataEvent(showLoading: true),
        );
      },
      allowShowLoading: true,
      title: el.tr(CcLocaleKeys.dashboard_refresh_data),
      bgColor: [
        context.ccColorScheme.primary,
        context.ccColorScheme.primary.withOpacity(0.8),
      ],
      textColor: context.ccColorScheme.onPrimary,
    );
  }
}
