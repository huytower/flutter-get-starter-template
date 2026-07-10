import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';

class CommentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => getIt<CommentController>());
  }
}

@lazySingleton
class CommentController extends CcGetController with PaginationMixin {
  CommentController(this._repository);

  final CommentRepository _repository;

  // Reactive list to store comments
  final comments = <CommentEntity>[].obs;

  @override
  void onReady() {
    super.onReady();

    // Initialize pagination with default settings
    initPagination(initialItemsPerPage: 20);

    // Initial load
    loadComments();
  }

  /// Load comments with pagination support.
  /// Set [refresh] to true to reload from the first page.
  Future<void> loadComments({bool refresh = false}) async {
    // 1. Guard check
    if (!canFetchMore && !refresh) return;

    // 2. Set loading states
    setPaginationLoading(true);
    layoutStatus.value = refresh
        ? CcLayoutStatus.loading
        : CcLayoutStatus.loadMore;

    // 3. Fetch data using the current request from mixin
    final result = await _repository.getComments(
      refresh
          ? const PaginationRequest(page: 1, itemsPerPage: 20)
          : currentPaginationRequest,
    );

    // 4. Update pagination logic (page counter and hasMore)
    handlePaginationResult(result, isRefresh: refresh);

    // 5. Handle UI State and Data updates
    result.when(
      (success) {
        if (refresh) {
          comments.assignAll(success);
        } else {
          comments.addAll(success);
        }

        // Determine final layout status
        if (comments.isEmpty) {
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

    // 6. Reset loading state
    setPaginationLoading(false);
  }

  /// Convenience method for load-more events
  Future<void> loadNextPage() => loadComments(refresh: false);

  /// Convenience method for pull-to-refresh events
  Future<void> refreshData() => loadComments(refresh: true);
}
