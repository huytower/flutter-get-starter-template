import 'package:injectable/injectable.dart';

import '../entities/budget_limit_stats_entity.dart';

@lazySingleton
class SortBudgetLimitsByProgressUseCase {
  List<BudgetLimitStatsEntity> call(
    List<BudgetLimitStatsEntity> stats, {
    int? limit,
  }) {
    final sorted = [...stats]
      ..sort((a, b) {
        final cmp = b.progress.compareTo(a.progress);
        if (cmp != 0) return cmp;
        return b.budget.limit.compareTo(a.budget.limit);
      });
    if (limit != null && sorted.length > limit) {
      sorted.removeRange(limit, sorted.length);
    }
    return sorted;
  }
}
