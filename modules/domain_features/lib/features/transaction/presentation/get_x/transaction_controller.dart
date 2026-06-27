import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
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
  TransactionController(this._repository);

  final TransactionRepository _repository;

  final RxInt selectedTabIndex = 0.obs;
  final transactions = <TransactionEntity>[].obs;

  void setTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  @override
  void onReady() {
    super.onReady();
    initPagination(initialItemsPerPage: 20);
    loadTransactions();
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (!canFetchMore && !refresh) return;

    setPaginationLoading(true);
    layoutStatus.value = refresh
        ? CcLayoutStatus.loading
        : CcLayoutStatus.loadMore;

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

        if (transactions.isEmpty) {
          layoutStatus.value = CcLayoutStatus.empty;
        } else {
          layoutStatus.value = CcLayoutStatus.success;
        }
      },
      (error) {
        errorMessage.value = error.message;
        layoutStatus.value = CcLayoutStatus.error;
      },
    );

    setPaginationLoading(false);
  }

  Future<void> loadNextPage() => loadTransactions(refresh: false);

  Future<void> refreshData() => loadTransactions(refresh: true);
}
