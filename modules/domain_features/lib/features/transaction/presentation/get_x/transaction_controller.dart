import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_balances_usecase.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => getIt<TransactionController>());
  }
}

@injectable
class TransactionController extends CcGetController with PaginationMixin {
  TransactionController(
    this._repository,
    this._getWalletBalances,
    this._walletRepository,
  );

  final TransactionRepository _repository;
  final GetWalletBalancesUseCase _getWalletBalances;
  final WalletRepository _walletRepository;

  final RxInt selectedTabIndex = 0.obs;
  final transactions = <TransactionEntity>[].obs;

  /// Total book balance across all wallets, shown in the header "Ví" chip.
  final RxInt walletTotal = 0.obs;

  /// Loading flag for the history list. The entry screen is always shown, so
  /// history uses this instead of [layoutStatus] (which stays `success`).
  final RxBool isLoading = false.obs;

  /// Shared wallet list for all forms to avoid duplicate API calls
  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final RxBool isLoadingWallets = false.obs;

  /// Temporary flag to show wallet summary in the AppBar for 2 seconds.
  final RxBool showWalletSummaryTemporarily = false.obs;

  void setTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  /// Temporarily shows the wallet summary in place of the title for 2 seconds.
  void flashWalletSummary() {
    showWalletSummaryTemporarily.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      showWalletSummaryTemporarily.value = false;
    });
  }

  @override
  void onInit() {
    super.onInit();
    // The transaction tab hosts an always-visible entry form, not a data-gated
    // list, so keep the layout in the success state.
    layoutStatus.value = CcLayoutStatus.success;
    initPagination(initialItemsPerPage: 20);
    refreshWalletTotal();
    loadWallets();
  }

  Future<void> loadWallets() async {
    isLoadingWallets.value = true;
    final result = await _walletRepository.getWallets();
    isLoadingWallets.value = false;
    result.when((walletList) => wallets.assignAll(walletList), (_) {});
  }

  Future<void> refreshWalletTotal() async {
    final result = await _getWalletBalances();
    result.when((balances) {
      walletTotal.value = balances.fold<int>(
        0,
        (sum, b) => sum + b.bookBalance,
      );
    }, (_) {});
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (!canFetchMore && !refresh) return;

    setPaginationLoading(true);
    isLoading.value = true;

    final result = await _repository.getTransactions(
      refresh
          ? const PaginationRequest(page: 1, itemsPerPage: 20)
          : currentPaginationRequest,
    );

    handlePaginationResult(result, isRefresh: refresh);

    result.when(
      (success) {
        if (refresh) {
          transactions.assignAll(success);
        } else {
          transactions.addAll(success);
        }
      },
      (error) {
        errorMessage.value = error.message;
      },
    );

    isLoading.value = false;
    setPaginationLoading(false);
  }

  Future<void> loadNextPage() => loadTransactions(refresh: false);

  Future<void> refreshData() async {
    await loadTransactions(refresh: true);
    await refreshWalletTotal();
  }
}
