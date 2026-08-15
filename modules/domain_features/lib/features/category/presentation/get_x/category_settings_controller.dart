import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../profile/domain/entities/profile_settings_entity.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../profile/domain/usecases/update_profile_settings_usecase.dart';
import '../../data/datasources/local/category_seed.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/category_group_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_category_groups_usecase.dart';
import '../../domain/usecases/toggle_category_enabled_usecase.dart';

@injectable
class CategorySettingsController extends CcGetController {
  CategorySettingsController(
    this._getGroups,
    this._getCategories,
    this._toggleEnabled,
    this._getProfileSettings,
    this._updateProfileSettings,
  );

  final GetCategoryGroupsUseCase _getGroups;
  final GetCategoriesUseCase _getCategories;
  final ToggleCategoryEnabledUseCase _toggleEnabled;
  final GetProfileSettingsUseCase _getProfileSettings;
  final UpdateProfileSettingsUseCase _updateProfileSettings;

  final RxList<CategoryGroupEntity> groups = <CategoryGroupEntity>[].obs;
  final RxMap<String, List<CategoryEntity>> byGroup =
      <String, List<CategoryEntity>>{}.obs;
  final RxMap<String, List<CategoryEntity>> incomeByGroup =
      <String, List<CategoryEntity>>{}.obs;
  final RxMap<String, List<CategoryEntity>> debtLoanByGroup =
      <String, List<CategoryEntity>>{}.obs;
  final RxMap<String, List<CategoryEntity>> investmentByGroup =
      <String, List<CategoryEntity>>{}.obs;

  final RxMap<String, bool> pending = <String, bool>{}.obs;
  final Rx<ProfileSettingsEntity> profileSettings =
      const ProfileSettingsEntity().obs;
  bool _categoriesLoaded = false;

  static final Rx<bool> onCategoryDefaultsApplied = false.obs;
  static final RxInt onCategoriesChanged = 0.obs;

  final Set<String> _inFlightToggleIds = {};

  /// Get recommended categories for the current age group
  List<String> getRecommendedCategoryKeys() {
    if (profileSettings.value.hasCustomizedCategories) return [];
    final birthYear = profileSettings.value.birthYear;
    if (birthYear == null) return [];
    final group = CategorySeed.ageGroup(birthYear);
    if (group == null) return [];
    return [
      ...CategorySeed.defaultExpenseCategoryKeys[group] ?? [],
      ...CategorySeed.defaultIncomeCategoryKeys[group] ?? [],
      ...CategorySeed.defaultDebtLoanCategoryKeys[group] ?? [],
      ...CategorySeed.defaultInvestmentCategoryKeys[group] ?? [],
    ];
  }

  Future<void> loadProfileSettings() async {
    final settings = await _getProfileSettings();
    profileSettings.value = settings;
  }

  @override
  void onInit() {
    super.onInit();
    _init();
    ever(profileSettings, _onProfileSettingsChanged);
  }

  Future<void> _init() async {
    await loadProfileSettings();
    await load();
  }

  void _onProfileSettingsChanged(ProfileSettingsEntity settings) {
    if (_categoriesLoaded &&
        !settings.hasCustomizedCategories &&
        settings.birthYear != null) {
      _applyAgeDefaults();
    }
  }

  Future<void> _applyAgeDefaults() async {
    final recommendedKeys = getRecommendedCategoryKeys();
    final allCategories = [
      ...byGroup.values.expand((e) => e),
      ...incomeByGroup.values.expand((e) => e),
      ...debtLoanByGroup.values.expand((e) => e),
      ...investmentByGroup.values.expand((e) => e),
    ];

    for (final cat in allCategories) {
      pending[cat.id] = recommendedKeys.contains(cat.nameKey);
    }
    pending.refresh();

    final futures = <Future>[];
    for (final cat in allCategories) {
      final shouldBeEnabled = recommendedKeys.contains(cat.nameKey);
      if (cat.isEnabled != shouldBeEnabled) {
        futures.add(_toggleEnabled(cat.id, shouldBeEnabled));
      }
    }
    await Future.wait(futures);

    if (Get.isRegistered<CategorySettingsController>()) {
      onCategoryDefaultsApplied.value = !onCategoryDefaultsApplied.value;
    }
  }

  Future<void> load() async {
    layoutStatus.value = CcLayoutStatus.loading;
    // Drop any optimistic-toggle overrides from a prior visit — this
    // controller is a permanent singleton, so without this a stale `pending`
    // entry would mask fresh isEnabled values fetched below forever (e.g.
    // categories toggled elsewhere, like ProfileController's age-based
    // defaults, would never show as changed on this page). Entries with a
    // toggle still in flight are kept so a concurrent load() (e.g. from
    // revisiting this page mid-write) can't visually revert an optimistic
    // update before its write actually lands.
    pending.removeWhere((id, _) => !_inFlightToggleIds.contains(id));
    final groupsResult = await _getGroups();
    final categoriesResult = await _getCategories();

    groupsResult.when((g) => groups.assignAll(g), (_) {});
    // Awaited: the success branch is async (it awaits the legacy-data
    // migration below, including a recursive load()), and Result.when
    // returns whatever that branch returns — without awaiting it here,
    // layoutStatus would flip to success while the migration/recursive
    // reload was still in flight, briefly showing an empty category list.
    await categoriesResult.when((categories) async {
      // FIX: Force migration for legacy Debt categories.
      // If we see IDs starting with 'd' but they aren't 'debtLoan' type, they are stale.
      final needsMigration = categories.any(
        (c) => c.id.startsWith('d') && c.type != CategoryType.debtLoan,
      );

      if (needsMigration) {
        'Fixing stale database records...'.Log('CategorySettingsController');
        for (final cat in categories) {
          if (cat.id.startsWith('d') || cat.id.startsWith('inv')) {
            // This triggers an update in CategoryLocalDataSource using the latest seed data
            await _toggleEnabled(cat.id, cat.isEnabled);
          }
        }
        await load(); // Recursive reload to pick up fixed data
        return;
      }

      // Create index map to preserve seed order
      final seedIndexMap = <String, int>{};
      for (int i = 0; i < CategorySeed.categories.length; i++) {
        seedIndexMap[CategorySeed.categories[i].id] = i;
      }

      final bg = <String, List<CategoryEntity>>{};
      final ibg = <String, List<CategoryEntity>>{};
      final dlbg = <String, List<CategoryEntity>>{};
      final invbg = <String, List<CategoryEntity>>{};
      for (final cat in categories) {
        if (cat.type == CategoryType.income) {
          ibg.putIfAbsent(cat.groupId, () => []).add(cat);
        } else if (cat.type == CategoryType.debtLoan) {
          dlbg.putIfAbsent(cat.groupId, () => []).add(cat);
        } else if (cat.type == CategoryType.investment) {
          invbg.putIfAbsent(cat.groupId, () => []).add(cat);
        } else {
          bg.putIfAbsent(cat.groupId, () => []).add(cat);
        }
      }

      // Sort each group by seed order to preserve the UX-optimized arrangement
      for (final group in bg.values) {
        group.sort((a, b) {
          final indexA = seedIndexMap[a.id] ?? 999;
          final indexB = seedIndexMap[b.id] ?? 999;
          return indexA.compareTo(indexB);
        });
      }
      for (final group in ibg.values) {
        group.sort((a, b) {
          final indexA = seedIndexMap[a.id] ?? 999;
          final indexB = seedIndexMap[b.id] ?? 999;
          return indexA.compareTo(indexB);
        });
      }
      for (final group in dlbg.values) {
        group.sort((a, b) {
          final indexA = seedIndexMap[a.id] ?? 999;
          final indexB = seedIndexMap[b.id] ?? 999;
          return indexA.compareTo(indexB);
        });
      }
      for (final group in invbg.values) {
        group.sort((a, b) {
          final indexA = seedIndexMap[a.id] ?? 999;
          final indexB = seedIndexMap[b.id] ?? 999;
          return indexA.compareTo(indexB);
        });
      }

      'Loaded categories: ${categories.length}'.Log(
        'CategorySettingsController',
      );
      'Debt/Loan groups: ${dlbg.keys.join(', ')}'.Log(
        'CategorySettingsController',
      );
      for (final entry in dlbg.entries) {
        'Group ${entry.key}: ${entry.value.length} items'.Log(
          'CategorySettingsController',
        );
      }

      byGroup.assignAll(bg);
      incomeByGroup.assignAll(ibg);
      debtLoanByGroup.assignAll(dlbg);
      investmentByGroup.assignAll(invbg);

      _categoriesLoaded = true;
      if (!profileSettings.value.hasCustomizedCategories &&
          profileSettings.value.birthYear != null) {
        _applyAgeDefaults();
      }
    }, (_) async {});

    layoutStatus.value = CcLayoutStatus.success;
  }

  bool isEnabled(CategoryEntity cat) =>
      pending.containsKey(cat.id) ? pending[cat.id]! : cat.isEnabled;

  void toggle(CategoryEntity cat) async {
    final current = isEnabled(cat);
    final next = !current;

    pending[cat.id] = next;
    pending.refresh();
    _inFlightToggleIds.add(cat.id);

    final result = await _toggleEnabled(cat.id, next);
    _inFlightToggleIds.remove(cat.id);
    if (result.isError()) {
      // Revert UI on error
      pending[cat.id] = current;
      pending.refresh();
    } else {
      // Mark user as having customized categories
      if (!profileSettings.value.hasCustomizedCategories) {
        final updatedSettings = profileSettings.value.copyWith(
          hasCustomizedCategories: true,
        );
        profileSettings.value = updatedSettings;
        await _updateProfileSettings(updatedSettings);
      }

      // Guideline: categories completed
      Get.find<GuidelineController>().completeTask('categories');

      // Global refresh for selection pickers
      onCategoriesChanged.value++;
    }
  }
}
