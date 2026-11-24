import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/contracts/financial_refresh_provider.dart';
import '../../../../core/contracts/guideline_provider.dart';
import '../../../category/export_category.dart';

/// Onboarding steps the profile triggers: default categories (by age group or
/// when full access is unlocked) and the matching guideline tasks.
@injectable
class ProfileOnboardingActions {
  ProfileOnboardingActions(
    this._toggleCategoryEnabled,
    this._refresh,
    this._guideline,
  );

  final ToggleCategoryEnabledUseCase _toggleCategoryEnabled;
  final FinancialRefreshProvider _refresh;
  final GuidelineProvider _guideline;

  GuidelineProvider get guideline => _guideline;

  /// Enables the given category `nameKey`s (mapped to their seed ids) so they
  /// appear checked in the category settings.
  Future<void> enableCategories(List<String> keys) async {
    final idByKey = {for (final c in CategorySeed.categories) c.nameKey: c.id};
    for (final key in keys) {
      final id = idByKey[key];
      if (id != null) await _toggleCategoryEnabled.call(id, true);
    }
  }

  /// Unlocking full access enables investment and liability categories so
  /// they appear in the UI immediately.
  Future<void> enableFullAccessCategories() => enableCategories(
    CategorySeed.categories
        .where(
          (c) =>
              c.type == CategoryType.investment ||
              c.type == CategoryType.liability,
        )
        .map((c) => c.nameKey)
        .toList(),
  );

  /// Applies the age group's default categories (unless the user already
  /// customized them) and completes the `birth_year` guideline task.
  Future<void> applyBirthYear(
    int year, {
    required bool hasCustomizedCategories,
  }) async {
    final group = CategorySeed.ageGroup(year);
    if (group == null) return;
    if (!hasCustomizedCategories) {
      await enableCategories([
        ...CategorySeed.defaultExpenseCategoryKeys[group]!,
        ...CategorySeed.defaultIncomeCategoryKeys[group]!,
        ...CategorySeed.defaultLiabilityCategoryKeys[group]!,
        ...CategorySeed.defaultInvestmentCategoryKeys[group]!,
        if (CategorySeed.qualifiesForFamilyDefaults(year))
          ...CategorySeed.familyCategoryKeys,
      ]);
    }
    unawaited(_guideline.completeTask('birth_year'));
  }

  void completeCategoriesTask() =>
      unawaited(_guideline.completeTask('categories'));

  /// Reloads the category settings screen if it is open.
  void refreshCategorySettings() =>
      unawaited(_refresh.refreshCategorySettings());

  /// Calls [listener] whenever guideline progress changes, if the guideline
  /// is running.
  void onGuidelineProgress(void Function(List<String> tasks) listener) {
    if (_guideline.hasAvailable) _guideline.onCompletedTasksChanged(listener);
  }
}
