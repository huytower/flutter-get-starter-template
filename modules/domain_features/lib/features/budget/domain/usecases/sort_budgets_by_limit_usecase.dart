import 'package:injectable/injectable.dart';

import '../entities/budget_stats_entity.dart';

/// Sorts budget stats by monthly limit, highest first — the order used by
/// overview surfaces (e.g. the Phân bổ budget preview).
///
/// Pure list transform (the input is not mutated) so callers can apply it to
/// an already-loaded reactive list; [limit] caps the result when set.
@lazySingleton
class SortBudgetsByLimitUseCase {
  List<BudgetStatsEntity> call(
    List<BudgetStatsEntity> stats, {
    int? limit,
  }) {
    final sorted = [...stats]
      ..sort((a, b) => b.budget.limit.compareTo(a.budget.limit));
    if (limit != null && sorted.length > limit) {
      sorted.removeRange(limit, sorted.length);
    }
    return sorted;
  }
}
