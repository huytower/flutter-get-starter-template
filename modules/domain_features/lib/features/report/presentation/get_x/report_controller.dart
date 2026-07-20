import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/entities/category_spending_entity.dart';
import '../../domain/entities/financial_runway_entity.dart';
import '../../domain/entities/trend_data_entity.dart';
import '../../domain/report_range.dart';
import '../../domain/usecases/get_category_spending_usecase.dart';
import '../../domain/usecases/get_financial_runway_usecase.dart';
import '../../domain/usecases/get_trend_data_usecase.dart';

@injectable
class ReportController extends CcGetController {
  ReportController(
    this._getCategorySpending,
    this._getFinancialRunway,
    this._getTrendData,
  );

  final GetCategorySpendingUseCase _getCategorySpending;
  final GetFinancialRunwayUseCase _getFinancialRunway;
  final GetTrendDataUseCase _getTrendData;

  final Rx<ReportRange> range = ReportRange.weekly.obs;
  final RxInt navigationOffset = 0.obs;

  /// True when the page header should be auto-hidden (scrolled down, or a
  /// soft keyboard is visible).
  final RxBool isHeaderHidden = false.obs;

  /// Scroll controller for the report body list, used to drive header hide.
  final ScrollController scrollController = ScrollController();

  void onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      isHeaderHidden.value = notification.metrics.pixels > 8;
    }
  }

  void onBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  final RxList<CategorySpendingEntity> spending =
      <CategorySpendingEntity>[].obs;
  final Rx<TrendDataEntity?> trendData = Rx<TrendDataEntity?>(null);
  final Rx<FinancialRunwayEntity?> runway = Rx<FinancialRunwayEntity?>(null);

  int get rangeExpense => spending.fold<int>(0, (sum, s) => sum + s.amount);

  bool get canNext => navigationOffset.value > 0;

  bool get canPrevious {
    if (range.value == ReportRange.monthly)
      return navigationOffset.value < 4; // Max 12 months (4 * 3)
    if (range.value == ReportRange.yearly)
      return navigationOffset.value < 1; // Max 1 year back
    return false;
  }

  @override
  void onReady() {
    super.onReady();
    load();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void selectRange(ReportRange next) {
    if (range.value == next) return;
    range.value = next;
    navigationOffset.value = 0;
    load(showLoading: false);
  }

  void nextPeriod() {
    if (canNext) {
      navigationOffset.value--;
      load(showLoading: false);
    }
  }

  void previousPeriod() {
    if (canPrevious) {
      navigationOffset.value++;
      load(showLoading: false);
    }
  }

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      layoutStatus.value = CcLayoutStatus.loading;
    }

    final bounds = range.value.bounds();

    final results = await Future.wait([
      _getCategorySpending.call(start: bounds.start, end: bounds.end),
      _getTrendData.call(range: range.value, offset: navigationOffset.value),
      _getFinancialRunway.call(),
    ]);

    final spendingResult =
        results[0] as Result<List<CategorySpendingEntity>, dynamic>;
    final trendResult = results[1] as Result<TrendDataEntity, dynamic>;
    final runwayResult = results[2] as Result<FinancialRunwayEntity, dynamic>;

    if (spendingResult.isError()) {
      errorMessage.value = spendingResult.tryGetError()!.title;
      layoutStatus.value = CcLayoutStatus.error;
      return;
    }

    spending.assignAll(spendingResult.tryGetSuccess()!);
    trendData.value = trendResult.tryGetSuccess();
    runway.value = runwayResult.tryGetSuccess();

    layoutStatus.value = CcLayoutStatus.success;
  }
}
