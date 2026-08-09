import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../domain/entities/category_spending_entity.dart';
import '../../domain/entities/financial_runway_entity.dart';
import '../../domain/entities/trend_data_entity.dart';
import '../../domain/report_range.dart';
import '../../domain/usecases/get_category_spending_usecase.dart';
import '../../domain/usecases/get_financial_runway_usecase.dart';
import '../../domain/usecases/get_investment_trend_usecase.dart';
import '../../domain/usecases/get_loan_trend_usecase.dart';
import '../../domain/usecases/get_trend_data_usecase.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../widgets/wallet_filter_picker_sheet.dart';

@injectable
class ReportController extends CcGetController {
  ReportController(
    this._getCategorySpending,
    this._getFinancialRunway,
    this._getTrendData,
    this._getInvestmentTrend,
    this._getLoanTrend,
    this._walletRepository,
    this.userLevel,
  );

  final GetCategorySpendingUseCase _getCategorySpending;
  final GetFinancialRunwayUseCase _getFinancialRunway;
  final GetTrendDataUseCase _getTrendData;
  final GetInvestmentTrendUseCase _getInvestmentTrend;
  final GetLoanTrendUseCase _getLoanTrend;
  final WalletRepository _walletRepository;

  /// Gates the Investment/Loan trend sections (see `report_page.dart`) —
  /// same LV2/LV3 unlock rule as every other Investment/Loan surface.
  final UserLevelController userLevel;

  /// Wallets offered by [WalletFilterPickerSheet]. Loaded once on ready,
  /// same shape as `TransactionController.wallets`/`loadWallets`.
  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;

  Future<void> loadWallets() async {
    final result = await _walletRepository.getWallets();
    result.when((walletList) => wallets.assignAll(walletList), (_) {});
  }

  /// Opens [WalletFilterPickerSheet] and applies the result: `null` (sheet
  /// dismissed) is a no-op, `''` clears the filter, otherwise sets it to the
  /// chosen wallet.
  Future<void> openWalletFilterPicker(BuildContext context) async {
    final result = await WalletFilterPickerSheet.show(
      context,
      wallets: wallets,
      selectedWalletId: filterWalletId.value,
    );
    if (result == null) return;
    if (result.isEmpty) {
      clearWalletFilter();
    } else {
      final wallet = wallets.firstWhere((w) => w.id == result);
      setWalletFilter(wallet.id, wallet.name);
      load(showLoading: false);
    }
  }

  final Rx<ReportRange> range = ReportRange.weekly.obs;
  final RxInt navigationOffset = 0.obs;

  /// Non-null when the report is scoped to a single wallet (entered via the
  /// Reconciliation page's per-wallet review shortcut).
  final RxnString filterWalletId = RxnString();
  final RxnString filterWalletName = RxnString();

  /// Anchor for [Scrollable.ensureVisible] once [requestScrollToDaily] has
  /// been requested and [load] finishes.
  final GlobalKey dailyDetailKey = GlobalKey();
  bool _pendingScrollToDaily = false;

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
  final Rx<TrendDataEntity?> investmentTrend = Rx<TrendDataEntity?>(null);
  final Rx<TrendDataEntity?> loanTrend = Rx<TrendDataEntity?>(null);

  int get rangeExpense => spending.fold<int>(0, (sum, s) => sum + s.amount);

  /// Merges the already period/wallet-filtered Income/Expense, Investment,
  /// and Loan transaction lists into one date-sorted feed for
  /// [ReportDailyList]. The three source lists are mutually exclusive by
  /// [TransactionEntity.type] (each usecase filters on a disjoint set of
  /// types), so a plain concat + sort is safe — no dedup needed.
  List<TransactionEntity> get dailyListTransactions {
    final combined = <TransactionEntity>[
      ...?trendData.value?.transactions,
      ...?investmentTrend.value?.transactions,
      ...?loanTrend.value?.transactions,
    ];
    combined.sort((a, b) => b.date.compareTo(a.date));
    return combined;
  }

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
    loadWallets();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void setWalletFilter(String walletId, String walletName) {
    filterWalletId.value = walletId;
    filterWalletName.value = walletName;
  }

  void clearWalletFilter() {
    filterWalletId.value = null;
    filterWalletName.value = null;
    load(showLoading: false);
  }

  void requestScrollToDaily() {
    _pendingScrollToDaily = true;
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
    final walletId = filterWalletId.value;

    final results = await Future.wait([
      _getCategorySpending.call(
        start: bounds.start,
        end: bounds.end,
        walletId: walletId,
      ),
      _getTrendData.call(
        range: range.value,
        offset: navigationOffset.value,
        walletId: walletId,
      ),
      _getFinancialRunway.call(),
      _getInvestmentTrend.call(
        range: range.value,
        offset: navigationOffset.value,
        walletId: walletId,
      ),
      _getLoanTrend.call(
        range: range.value,
        offset: navigationOffset.value,
        walletId: walletId,
      ),
    ]);

    final spendingResult =
        results[0] as Result<List<CategorySpendingEntity>, dynamic>;
    final trendResult = results[1] as Result<TrendDataEntity, dynamic>;
    final runwayResult = results[2] as Result<FinancialRunwayEntity, dynamic>;
    final investmentTrendResult =
        results[3] as Result<TrendDataEntity, dynamic>;
    final loanTrendResult = results[4] as Result<TrendDataEntity, dynamic>;

    if (spendingResult.isError()) {
      errorMessage.value = spendingResult.tryGetError()!.title;
      layoutStatus.value = CcLayoutStatus.error;
      return;
    }

    spending.assignAll(spendingResult.tryGetSuccess()!);
    trendData.value = trendResult.tryGetSuccess();
    runway.value = runwayResult.tryGetSuccess();
    investmentTrend.value = investmentTrendResult.tryGetSuccess();
    loanTrend.value = loanTrendResult.tryGetSuccess();

    layoutStatus.value = CcLayoutStatus.success;

    if (_pendingScrollToDaily) {
      _pendingScrollToDaily = false;
      _scrollToDailyDetail();
    }
  }

  /// The daily-detail section is built for the first time in the same
  /// [load] call that requested the scroll, so its [dailyDetailKey] context
  /// may not exist yet on the very next frame (loading→success and the
  /// trendData-null→non-null Obx rebuilds can each take a frame). Retries
  /// across a few frames instead of a single post-frame callback. Requires
  /// the report ListView to eagerly mount off-screen children (see its
  /// `cacheExtent`) — otherwise a lazily-unmounted target never gets a
  /// BuildContext no matter how many frames are retried.
  void _scrollToDailyDetail([int attemptsLeft = 20]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = dailyDetailKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (attemptsLeft > 0) {
        _scrollToDailyDetail(attemptsLeft - 1);
      }
    });
  }
}
