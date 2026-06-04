part of 'dashboard_bloc.dart';

/// Dashboard Events - Presentation Layer
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

/// Event to load dashboard data
class LoadDashboardDataEvent extends DashboardEvent {
  const LoadDashboardDataEvent();
}

/// Event to refresh dashboard data
class RefreshDashboardDataEvent extends DashboardEvent {
  final bool showLoading;

  const RefreshDashboardDataEvent({this.showLoading = true});

  @override
  List<Object> get props => [showLoading];
}

/// Event to increment item count
class IncrementItemCountEvent extends DashboardEvent {
  final bool showLoading;

  const IncrementItemCountEvent({this.showLoading = true});

  @override
  List<Object> get props => [showLoading];
}

/// Event to decrement item count
class DecrementItemCountEvent extends DashboardEvent {
  final bool showLoading;

  const DecrementItemCountEvent({this.showLoading = true});

  @override
  List<Object> get props => [showLoading];
}
