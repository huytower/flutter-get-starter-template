import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_content.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FadePageWrapper(
      child: BlocProvider(
        create: (_) =>
            getIt<DashboardBloc>()..add(const LoadDashboardDataEvent()),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) => DashboardView(state, context),
        ),
      ),
    );
  }
}

class DashboardView extends StatelessWidget with CcViewConfigMixin {
  final DashboardState state;
  final BuildContext blocContext;

  const DashboardView(this.state, this.blocContext, {super.key});

  @override
  bool get isEnableLoading => false;

  @override
  CcLayoutStatus get layoutStatus => _getLayoutStatus();

  /// Determine layout status based on current state
  CcLayoutStatus _getLayoutStatus() {
    if (state is DashboardLoading) return CcLayoutStatus.loading;
    if (state is DashboardError) return CcLayoutStatus.error;
    if (state is DashboardLoaded) return CcLayoutStatus.success;
    return CcLayoutStatus.success;
  }

  @override
  String get errorMessage => _getErrorMessage();

  /// Get error message from state or default
  String _getErrorMessage() {
    if (state is DashboardError) {
      return (state as DashboardError).message;
    }
    return super.errorMessage;
  }

  @override
  PreferredSizeWidget? appBar() => DashboardAppBar(blocContext: blocContext);

  @override
  Widget? buildContent() => _buildContent();

  /// Build content widget based on state
  Widget? _buildContent() {
    if (state is! DashboardLoaded) return null;

    final loadedState = state as DashboardLoaded;
    return DashboardContent(
      dashboardData: loadedState.dashboardData,
      isRefreshing: state is DashboardRefreshing,
      isUpdating: state is DashboardUpdating,
    );
  }
}
