import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/dashboard_bloc.dart';

class DashboardCounterCard extends StatelessWidget {
  final int itemCount;

  const DashboardCounterCard({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return CcCard(
      width: double.infinity,
      child: Column(
        children: [
          CcText(
            el.tr(CcLocaleKeys.dashboard_item_count),
            textStyle: context.ccTextTheme.titleLarge,
            align: Alignment.center,
          ),
          const CcSpaceLG(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CcInteractBtnWrapper(
                useDebounce: true,
                isBouncing: true,
                onTap: () {
                  context.read<DashboardBloc>().add(
                    const DecrementItemCountEvent(showLoading: false),
                  );
                },
                child: Icon(
                  Icons.remove_circle_outline,
                  size: context.respIconSize(),
                  color: context.ccColorScheme.error,
                ),
              ),
              const CcSpaceXL(),
              CcText(
                '$itemCount',
                textStyle: context.ccTextTheme.headlineLarge?.copyWith(
                  color: context.ccColorScheme.secondary,
                  fontWeight: CcTypographyParams.bold,
                ),
              ),
              const CcSpaceXL(),
              CcInteractBtnWrapper(
                useDebounce: true,
                isBouncing: true,
                onTap: () {
                  context.read<DashboardBloc>().add(
                    const IncrementItemCountEvent(showLoading: false),
                  );
                },
                child: Icon(
                  Icons.add_circle_outline,
                  size: context.respIconSize(),
                  color: context.ccColorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
