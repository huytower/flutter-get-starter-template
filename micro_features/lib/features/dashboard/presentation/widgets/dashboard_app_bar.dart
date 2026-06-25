import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_bloc.dart';

/// Dashboard app bar widget with title and refresh action
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BuildContext blocContext;

  const DashboardAppBar({super.key, required this.blocContext});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(context),
      actions: [_buildRefreshButton(context)],
    );
  }

  /// Build the app bar title with localized text
  Widget _buildTitle(BuildContext context) {
    return CcText(
      el.tr(CcLocaleKeys.nav_dashboard),
      textStyle: context.ccTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: context.respFontSize(CcTypographyParams.titleLarge),
      ),
    );
  }

  /// Build the refresh action button
  Widget _buildRefreshButton(BuildContext context) {
    return CcInteractBtnWrapper(
      onTap: () => blocContext.read<DashboardBloc>().add(
        const RefreshDashboardDataEvent(),
      ),
      useDebounce: true,
      isBouncing: true,
      child: Padding(
        padding: EdgeInsets.only(
          right: context.respPadding(CcPaddingParams.SPACE_MD),
        ),
        child: Icon(
          Icons.refresh,
          color: context.ccColorScheme.primary,
          size: context.respIconSize(),
        ),
      ),
    );
  }
}
