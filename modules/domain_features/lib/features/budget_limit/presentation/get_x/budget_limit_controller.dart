import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/entities/budget_limit_stats_entity.dart';
import '../../domain/usecases/create_budget_limit_usecase.dart';
import '../../domain/usecases/delete_budget_limit_usecase.dart';
import '../../domain/usecases/get_budget_limit_stats_usecase.dart';
import '../../domain/usecases/update_budget_limit_orders_usecase.dart';
import '../../domain/usecases/update_budget_limit_usecase.dart';

class BudgetLimitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => getIt<BudgetLimitController>());
  }
}

@injectable
class BudgetLimitController extends CcGetController {
  BudgetLimitController(
    this._getBudgetStats,
    this._createBudget,
    this._updateBudget,
    this._updateBudgetOrders,
    this._deleteBudget,
  );

  final GetBudgetLimitStatsUseCase _getBudgetStats;
  final CreateBudgetLimitUseCase _createBudget;
  final UpdateBudgetLimitUseCase _updateBudget;
  final UpdateBudgetLimitOrdersUseCase _updateBudgetOrders;
  final DeleteBudgetLimitUseCase _deleteBudget;

  final RxList<BudgetLimitStatsEntity> budgets = <BudgetLimitStatsEntity>[].obs;
  final RxBool isEditMode = false.obs;

  void toggleEditMode() => isEditMode.toggle();

  @override
  void onReady() {
    super.onReady();
    loadBudgets();
    print("BudgetLimitController initialized");
  }

  /// Fetches budgets and their computed spend.
  ///
  /// Pass [showLoading] as false for background refreshes (e.g. re-opening the
  /// tab) so already-loaded data isn't replaced by a full-screen loader.
  Future<void> loadBudgets() async {
    layoutStatus.value = CcLayoutStatus.loading;

    final result = await _getBudgetStats.call();
    result.when(
      (success) {
        budgets.assignAll(success);
        layoutStatus.value = CcLayoutStatus.success;
      },
      (error) {
        errorMessage.value = error.message;
        layoutStatus.value = CcLayoutStatus.error;
      },
    );
  }

  /// Returns null on success, or an error message to surface to the user.
  Future<String?> createBudget(CreateBudgetLimitParams params) async {
    final result = await _createBudget.call(params);
    return result.when((_) {
      loadBudgets();
      return null;
    }, (error) => error.message);
  }

  Future<String?> updateBudget(String id, {String? name, int? limit}) async {
    final result = await _updateBudget.call(id, name: name, limit: limit);
    return result.when((_) {
      loadBudgets();
      return null;
    }, (error) => error.message);
  }

  /// Moves the budget at [oldIndex] to [newIndex] (ReorderableListView
  /// semantics) — optimistic UI update, then persisted.
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final item = budgets.removeAt(oldIndex);
    budgets.insert(newIndex, item);

    final result = await _updateBudgetOrders.call(
      budgets.map((s) => s.budget.id).toList(),
    );
    result.when((_) {}, (error) {
      errorMessage.value = error.message;
      loadBudgets();
    });
  }

  /// Swaps positions of the budgets at [fromIndex] and [toIndex] (grid drag-to-reorder).
  Future<void> swapBudgets(int fromIndex, int toIndex) async {
    if (fromIndex == toIndex) return;
    if (fromIndex < 0 || toIndex < 0) return;
    if (fromIndex >= budgets.length || toIndex >= budgets.length) return;

    final tmp = budgets[fromIndex];
    budgets[fromIndex] = budgets[toIndex];
    budgets[toIndex] = tmp;

    final result = await _updateBudgetOrders.call(
      budgets.map((s) => s.budget.id).toList(),
    );
    result.when((_) {}, (error) {
      errorMessage.value = error.message;
      loadBudgets();
    });
  }

  Future<void> deleteBudget(String id) async {
    final result = await _deleteBudget.call(id);
    result.when(
      (_) => loadBudgets(),
      (error) => errorMessage.value = error.message,
    );
  }
}
