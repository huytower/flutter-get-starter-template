import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/entities/budget_stats_entity.dart';
import '../../domain/usecases/create_budget_usecase.dart';
import '../../domain/usecases/delete_budget_usecase.dart';
import '../../domain/usecases/get_budget_stats_usecase.dart';
import '../../domain/usecases/reset_budget_usecase.dart';
import '../../domain/usecases/update_budget_limit_usecase.dart';

class BudgetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => getIt<BudgetController>());
  }
}

@injectable
class BudgetController extends CcGetController {
  BudgetController(
    this._getBudgetStats,
    this._createBudget,
    this._updateBudgetLimit,
    this._resetBudget,
    this._deleteBudget,
  );

  final GetBudgetStatsUseCase _getBudgetStats;
  final CreateBudgetUseCase _createBudget;
  final UpdateBudgetLimitUseCase _updateBudgetLimit;
  final ResetBudgetUseCase _resetBudget;
  final DeleteBudgetUseCase _deleteBudget;

  final RxList<BudgetStatsEntity> budgets = <BudgetStatsEntity>[].obs;

  @override
  void onReady() {
    super.onReady();
    loadBudgets();
  }

  /// Fetches budgets and their computed spend.
  ///
  /// Pass [showLoading] as false for background refreshes (e.g. re-opening the
  /// tab) so already-loaded data isn't replaced by a full-screen loader.
  Future<void> loadBudgets({bool showLoading = true}) async {
    if (showLoading) {
      layoutStatus.value = CcLayoutStatus.loading;
    }
    final result = await _getBudgetStats.call();
    result.when(
      (success) {
        budgets.assignAll(success);
        layoutStatus.value =
            success.isEmpty ? CcLayoutStatus.empty : CcLayoutStatus.success;
      },
      (error) {
        errorMessage.value = error.message;
        layoutStatus.value = CcLayoutStatus.error;
      },
    );
  }

  /// Returns null on success, or an error message to surface to the user.
  Future<String?> createBudget(CreateBudgetParams params) async {
    final result = await _createBudget.call(params);
    return result.when(
      (_) {
        loadBudgets();
        return null;
      },
      (error) => error.message,
    );
  }

  Future<String?> updateLimit(String id, int newLimit) async {
    final result = await _updateBudgetLimit.call(id, newLimit);
    return result.when(
      (_) {
        loadBudgets();
        return null;
      },
      (error) => error.message,
    );
  }

  Future<String?> resetBudget(String oldId, CreateBudgetParams newData) async {
    final result = await _resetBudget.call(oldId, newData);
    return result.when(
      (_) {
        loadBudgets();
        return null;
      },
      (error) => error.message,
    );
  }

  Future<void> deleteBudget(String id) async {
    final result = await _deleteBudget.call(id);
    result.when(
      (_) => loadBudgets(),
      (error) => errorMessage.value = error.message,
    );
  }
}
