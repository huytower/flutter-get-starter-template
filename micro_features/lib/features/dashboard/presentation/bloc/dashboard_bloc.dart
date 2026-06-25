import 'package:bloc/bloc.dart';
import 'package:data/domain/entities/dashboard/dashboard_entity.dart';
import 'package:data/domain/usecases/dashboard/get_dashboard_data_usecase.dart';
import 'package:data/domain/usecases/dashboard/refresh_dashboard_data_usecase.dart';
import 'package:data/domain/usecases/dashboard/update_dashboard_data_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase _getDashboardDataUseCase;
  final UpdateDashboardDataUseCase _updateDashboardDataUseCase;
  final RefreshDashboardDataUseCase _refreshDashboardDataUseCase;

  DashboardBloc({
    required GetDashboardDataUseCase getDashboardDataUseCase,
    required UpdateDashboardDataUseCase updateDashboardDataUseCase,
    required RefreshDashboardDataUseCase refreshDashboardDataUseCase,
  }) : _getDashboardDataUseCase = getDashboardDataUseCase,
       _updateDashboardDataUseCase = updateDashboardDataUseCase,
       _refreshDashboardDataUseCase = refreshDashboardDataUseCase,
       super(const DashboardInitial()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<RefreshDashboardDataEvent>(_onRefreshDashboardData);
    on<IncrementItemCountEvent>(_onIncrementItemCount);
    on<DecrementItemCountEvent>(_onDecrementItemCount);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    final result = await _getDashboardDataUseCase();
    result.when(
      (data) => emit(DashboardLoaded(data)),
      (failure) => emit(DashboardError(failure.message)),
    );
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardDataEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (event.showLoading) {
      if (currentState is DashboardLoaded) {
        emit(DashboardRefreshing(currentState.dashboardData));
      } else {
        emit(const DashboardLoading());
      }
    }

    final result = await _refreshDashboardDataUseCase();
    result.when(
      (data) => emit(DashboardLoaded(data)),
      (failure) => emit(DashboardError(failure.message)),
    );
  }

  Future<void> _onIncrementItemCount(
    IncrementItemCountEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      final newData = currentState.dashboardData.copyWith(
        itemCount: currentState.dashboardData.itemCount + 1,
      );

      if (event.showLoading) {
        emit(DashboardUpdating(newData));
      }

      final result = await _updateDashboardDataUseCase(newData);
      result.when(
        (updatedData) => emit(DashboardLoaded(updatedData)),
        (failure) => emit(DashboardError(failure.message)),
      );
    }
  }

  Future<void> _onDecrementItemCount(
    DecrementItemCountEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      final newData = currentState.dashboardData.copyWith(
        itemCount: currentState.dashboardData.itemCount - 1,
      );

      if (event.showLoading) {
        emit(DashboardUpdating(newData));
      }

      final result = await _updateDashboardDataUseCase(newData);
      result.when(
        (updatedData) => emit(DashboardLoaded(updatedData)),
        (failure) => emit(DashboardError(failure.message)),
      );
    }
  }
}
