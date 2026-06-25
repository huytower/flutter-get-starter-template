part of 'dashboard_bloc.dart';

/// Dashboard States - Presentation Layer
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state
class DashboardLoaded extends DashboardState {
  final DashboardEntity dashboardData;

  const DashboardLoaded(this.dashboardData);

  @override
  List<Object?> get props => [dashboardData];
}

/// Refreshing state
class DashboardRefreshing extends DashboardLoaded {
  const DashboardRefreshing(super.dashboardData);
}

/// Updating state
class DashboardUpdating extends DashboardLoaded {
  const DashboardUpdating(super.dashboardData);
}

/// Error state
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
