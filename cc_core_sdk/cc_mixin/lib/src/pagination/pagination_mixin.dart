import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:multiple_result/multiple_result.dart';

/// [PaginationMixin] is a state-management agnostic logic handler for paginated data.
///
/// It manages the arithmetic of page numbers, loading states, and the availability
/// of more data ("hasMore") without depending on any specific state management
/// library like GetX, Bloc, or Riverpod.
///
/// ### Core Responsibilities:
/// 1. Tracking current page and items per page.
/// 2. Generating [PaginationRequest] objects for data sources.
/// 3. Determining if more data is available based on results.
/// 4. Managing internal loading state to prevent duplicate requests.
///
/// ### Usage (General Logic):
/// ```dart
/// class MyDataHandler with PaginationMixin {
///   Future<void> fetchData() async {
///     if (!canFetchMore) return;
///
///     setPaginationLoading(true);
///
///     // 1. Use [currentPaginationRequest] for the API call
///     final result = await repository.getData(currentPaginationRequest);
///
///     // 2. Process result to update pagination metadata
///     handlePaginationResult(result);
///
///     setPaginationLoading(false);
///   }
/// }
/// ```
///
/// ### Usage (GetX Controller Implementation Example):
/// ```dart
/// class MyController extends CcGetController with PaginationMixin {
///   final items = <Entity>[].obs;
///
///   Future<void> loadNext({bool refresh = false}) async {
///      if (!canFetchMore && !refresh) return;
///
///      setPaginationLoading(true);
///
///      final result = await ccFetchData(
///        fetchFunction: () => repo.get(currentPaginationRequest),
///      );
///
///      handlePaginationResult(result, isRefresh: refresh);
///
///      if (isFirstPage) items.assignAll(result.getSuccess() ?? []);
///      else items.addAll(result.getSuccess() ?? []);
///
///      setPaginationLoading(false);
///   }
/// }
/// ```
mixin PaginationMixin {
  int _currentPage = 1;
  int _itemsPerPage = 20;
  bool _hasMore = true;
  bool _isLoading = false;

  // --- Getters ---

  /// The current page number (1-based index).
  int get currentPage => _currentPage;

  /// Number of items requested per page.
  int get itemsPerPage => _itemsPerPage;

  /// True if there is more data to fetch based on previous results.
  bool get hasMore => _hasMore;

  /// True if a pagination request is currently in progress.
  bool get isPaginationLoading => _isLoading;

  /// Returns true if more data can be fetched (not currently loading and has more items).
  bool get canFetchMore => _hasMore && !_isLoading;

  /// Returns true if the pagination is currently at the first page.
  bool get isFirstPage => _currentPage == 1;

  /// Generates a [PaginationRequest] based on the current internal state.
  PaginationRequest get currentPaginationRequest =>
      PaginationRequest(page: _currentPage, itemsPerPage: _itemsPerPage);

  // --- Actions ---

  /// Initializes the pagination state with optional page size configuration.
  void initPagination({int initialItemsPerPage = 20}) {
    _itemsPerPage = initialItemsPerPage;
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
  }

  /// Resets pagination to the first page.
  void resetPagination() {
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
  }

  /// Manually updates the internal loading state.
  void setPaginationLoading(bool loading) {
    _isLoading = loading;
  }

  /// Processes a [Result] from a data source to update pagination metadata.
  ///
  /// - On [Success]: Updates [_hasMore] by checking if the returned list size
  ///   matches the [_itemsPerPage]. Increments the page counter if more data is available.
  /// - On [Error]: Returns the original error result for the caller to handle.
  ///
  /// Set [isRefresh] to true to reset the state to the first page before processing.
  Result<List<T>, Failure> handlePaginationResult<T>(
    Result<List<T>, Failure> result, {
    bool isRefresh = false,
  }) {
    if (isRefresh) resetPagination();

    return result.when(
      (data) {
        // If we received fewer items than requested, we've reached the end of the data set.
        if (data.length < _itemsPerPage) {
          _hasMore = false;
        } else {
          _hasMore = true;
          _currentPage++;
        }
        return Success(data);
      },
      (error) {
        // By default, we keep current hasMore state on error.
        // The caller (Controller/Bloc) should handle the UI error state.
        return Error(error);
      },
    );
  }
}
