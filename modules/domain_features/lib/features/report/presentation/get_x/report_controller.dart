import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/entities/category_spending_entity.dart';
import '../../domain/entities/monthly_summary_entity.dart';
import '../../domain/report_range.dart';
import '../../domain/usecases/get_category_spending_usecase.dart';
import '../../domain/usecases/get_monthly_summary_usecase.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => getIt<ReportController>());
  }
}

@injectable
class ReportController extends CcGetController {
  ReportController(this._getCategorySpending, this._getMonthlySummary);

  final GetCategorySpendingUseCase _getCategorySpending;
  final GetMonthlySummaryUseCase _getMonthlySummary;

  /// Number of months shown in the trend bar chart.
  static const int _trendMonths = 6;

  final Rx<ReportRange> range = ReportRange.thisWeek.obs;
  final RxList<CategorySpendingEntity> spending =
      <CategorySpendingEntity>[].obs;
  final RxList<MonthlySummaryEntity> monthly = <MonthlySummaryEntity>[].obs;

  /// Total expense over the selected range (sum of pie slices).
  int get rangeExpense =>
      spending.fold<int>(0, (sum, s) => sum + s.amount);

  @override
  void onReady() {
    super.onReady();
    load();
  }

  /// Switches the pie's time window and reloads.
  void selectRange(ReportRange next) {
    if (range.value == next) return;
    range.value = next;
    load(showLoading: false);
  }

  /// Loads both charts. Pass [showLoading] false for background refreshes so
  /// existing data isn't replaced by a full-screen loader.
  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      layoutStatus.value = CcLayoutStatus.loading;
    }

    final bounds = range.value.bounds();
    final results = await Future.wait([
      _getCategorySpending.call(start: bounds.start, end: bounds.end),
      _getMonthlySummary.call(months: _trendMonths),
    ]);

    final spendingResult = results[0];
    if (spendingResult.isError()) {
      errorMessage.value = spendingResult.tryGetError()!.message;
      layoutStatus.value = CcLayoutStatus.error;
      return;
    }
    final monthlyResult = results[1];
    if (monthlyResult.isError()) {
      errorMessage.value = monthlyResult.tryGetError()!.message;
      layoutStatus.value = CcLayoutStatus.error;
      return;
    }

    spending.assignAll(
      spendingResult.tryGetSuccess()!.cast<CategorySpendingEntity>(),
    );
    monthly.assignAll(
      monthlyResult.tryGetSuccess()!.cast<MonthlySummaryEntity>(),
    );

    // The screen still has value (trend chart + range switcher) even with no
    // spending yet, so only the pie shows an inline empty hint — keep the page
    // in the success state rather than the global empty placeholder.
    layoutStatus.value = CcLayoutStatus.success;
  }
}
