import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/helper/ai_advice_cache_datasource.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../domain/entities/ai_advice_entity.dart';
import '../../domain/entities/category_spending_entity.dart';
import '../../domain/entities/financial_runway_entity.dart';
import '../../domain/entities/trend_data_entity.dart';
import '../../domain/report_range.dart';
import '../../domain/usecases/generate_ai_financial_advice_usecase.dart';
import '../../domain/usecases/get_category_spending_usecase.dart';
import '../../domain/usecases/get_financial_runway_usecase.dart';
import '../../domain/usecases/get_investment_trend_usecase.dart';
import '../../domain/usecases/get_loan_trend_usecase.dart';
import '../../domain/usecases/get_trend_data_usecase.dart';
import '../widgets/wallet_filter_picker_sheet.dart';

@injectable
class ReportController extends CcGetController {
  ReportController(
    this._getCategorySpending,
    this._getFinancialRunway,
    this._getTrendData,
    this._getInvestmentTrend,
    this._getLiabilityTrend,
    this._walletRepository,
    this.userLevel,
    this._generateAiAdvice,
    this._aiAdviceCache,
  );

  final GetCategorySpendingUseCase _getCategorySpending;
  final GetFinancialRunwayUseCase _getFinancialRunway;
  final GetTrendDataUseCase _getTrendData;
  final GetInvestmentTrendUseCase _getInvestmentTrend;
  final GetLoanTrendUseCase _getLiabilityTrend;
  final WalletRepository _walletRepository;
  final GenerateAiFinancialAdviceUseCase _generateAiAdvice;
  final AiAdviceCacheDataSource _aiAdviceCache;
  final UserLevelController userLevel;

  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;

  Future<void> loadWallets() async {
    final result = await _walletRepository.getWallets();
    result.when((walletList) => wallets.assignAll(walletList), (_) {});
  }

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
  final RxnString filterWalletId = RxnString();
  final RxnString filterWalletName = RxnString();

  final GlobalKey dailyDetailKey = GlobalKey();
  bool _pendingScrollToDaily = false;

  final RxBool isHeaderHidden = false.obs;
  final RxBool isEditMode = false.obs;

  void toggleEditMode() {
    isEditMode.toggle();
  }

  final ScrollController scrollController = ScrollController();

  void onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      isHeaderHidden.value = notification.metrics.pixels > 8;
    }
  }

  void onBack(BuildContext context) {
    if (isEditMode.value) {
      isEditMode.value = false;
    } else {
      Navigator.of(context).pop();
    }
  }

  final RxList<CategorySpendingEntity> spending =
      <CategorySpendingEntity>[].obs;
  final Rx<TrendDataEntity?> trendData = Rx<TrendDataEntity?>(null);
  final Rx<FinancialRunwayEntity?> runway = Rx<FinancialRunwayEntity?>(null);
  final Rx<TrendDataEntity?> investmentTrend = Rx<TrendDataEntity?>(null);
  final Rx<TrendDataEntity?> liabilityTrend = Rx<TrendDataEntity?>(null);

  final Rx<AiAdviceEntity?> aiAdvice = Rx<AiAdviceEntity?>(null);
  final RxBool isGeneratingAdvice = false.obs;
  final RxnString aiAdviceErrorKey = RxnString();

  int get rangeExpense => spending.fold<int>(0, (sum, s) => sum + s.amount);

  List<TransactionEntity> get dailyListTransactions {
    final combined = <TransactionEntity>[
      ...?trendData.value?.transactions,
      ...?investmentTrend.value?.transactions,
      ...?liabilityTrend.value?.transactions,
    ];

    combined.sort((a, b) {
      // Primary: Date descending (newest first)
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;

      // Secondary: ID descending (last recorded first).
      // Since IDs are microsecondsSinceEpoch strings, we compare them
      // numerically by checking length first, then alphabetical.
      if (b.id.length != a.id.length) {
        return b.id.length.compareTo(a.id.length);
      }
      return b.id.compareTo(a.id);
    });

    return combined;
  }

  bool get canNext => navigationOffset.value > 0;

  bool get canPrevious {
    if (range.value == ReportRange.monthly) return navigationOffset.value < 4;
    if (range.value == ReportRange.yearly) return navigationOffset.value < 1;
    return false;
  }

  @override
  void onReady() {
    super.onReady();
    isEditMode.value = false;
    load();
    loadWallets();
    loadCachedAiAdvice();
  }

  @override
  void onClose() {
    isEditMode.value = false;
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadCachedAiAdvice() async {
    final text = await _aiAdviceCache.getCachedText();
    final generatedAt = await _aiAdviceCache.getCachedGeneratedAt();
    if (text != null && generatedAt != null) {
      aiAdvice.value = AiAdviceEntity(text: text, generatedAt: generatedAt);
    }
  }

  Future<void> generateAiAdvice(BuildContext context) async {
    if (!userLevel.status.value.isVip) return;

    if (isGeneratingAdvice.value) return;
    isGeneratingAdvice.value = true;
    aiAdviceErrorKey.value = null;

    final prefs = getIt<AiFallbackPreferenceDataSource>();
    if (!await prefs.tryConsumeDailyCall()) {
      if (isClosed) return;
      isGeneratingAdvice.value = false;
      aiAdviceErrorKey.value =
          CcLocaleKeys.report_ai_advice_daily_limit_reached;
      return;
    }

    final result = await _generateAiAdvice.call();
    if (isClosed) return;
    isGeneratingAdvice.value = false;

    if (result == null) {
      aiAdviceErrorKey.value = CcLocaleKeys.report_ai_advice_generate_failed;
      return;
    }
    aiAdvice.value = result;
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
      _getLiabilityTrend.call(
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
    final liabilityTrendResult = results[4] as Result<TrendDataEntity, dynamic>;

    if (spendingResult.isError()) {
      errorMessage.value = spendingResult.tryGetError()!.title;
      layoutStatus.value = CcLayoutStatus.error;
      return;
    }

    spending.assignAll(spendingResult.tryGetSuccess()!);
    trendData.value = trendResult.tryGetSuccess();
    runway.value = runwayResult.tryGetSuccess();
    investmentTrend.value = investmentTrendResult.tryGetSuccess();
    liabilityTrend.value = liabilityTrendResult.tryGetSuccess();

    layoutStatus.value = CcLayoutStatus.success;

    if (_pendingScrollToDaily) {
      _pendingScrollToDaily = false;
      _scrollToDailyDetail();
    }
  }

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
