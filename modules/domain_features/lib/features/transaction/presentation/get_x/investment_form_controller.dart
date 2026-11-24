import 'dart:async';

import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:collection/collection.dart' hide IterableFirstOrNull;
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/presentation/helper/horizontal_row_reveal.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:domain_features/features/firestore/guest_login_prompt_service.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';

import '../../../../core/budget/budget_name_helper.dart';
import '../../../../core/constant/currency_constants.dart';
import '../../../../core/constant/money_constants.dart';
import '../../../../core/currency/money_formatter.dart';
import '../../../../core/di/di.dart';
import '../../../../core/quick_entry/quick_entry_intent.dart';
import '../../../../core/quick_entry/quick_entry_intent_util.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/entities/investment_direction.dart';
import '../../domain/usecases/create_investment_transaction_usecase.dart';
import 'quick_entry_handler.dart';
import 'quick_entry_session.dart';
import 'transaction_controller.dart';
import 'transaction_form_controller.dart';

const String _debugTag = 'InvestmentAssetRow';

@injectable
class InvestmentFormController extends TransactionFormController {
  InvestmentFormController(
    this._getCategories,
    this._getProfileSettings,
    this._createInvestmentTransaction,
    this._guidelineProvider,
    this.quickEntryHandler,
  );

  final QuickEntryHandler quickEntryHandler;

  @override
  late final QuickEntrySession quickEntry = QuickEntrySession(
    this,
    quickEntryHandler,
  );

  final GuidelineProvider _guidelineProvider;

  final GetCategoriesUseCase _getCategories;
  final GetProfileSettingsUseCase _getProfileSettings;
  final CreateInvestmentTransactionUseCase _createInvestmentTransaction;

  @override
  String get quickEntryCategoryType => CategoryType.investment;

  /// Pre-fills the investment asset selection from a resolved category id.
  /// If an existing investment wallet matches the category, it selects it.
  /// Otherwise, it selects the base category to prepare for adding a new asset.
  @override
  void applyQuickEntryCategory(String categoryId) {
    final text = quickEntry.quickEntryController.text.toLowerCase();

    // 1. Try to find an existing investment wallet for this category
    final matchingWallets = mergedItems
        .whereType<WalletEntity>()
        .where((w) => w.categoryId == categoryId)
        .toList();

    if (matchingWallets.isNotEmpty) {
      WalletEntity selected = matchingWallets.first;

      // If multiple wallets for this category, try to match by name in the text
      if (matchingWallets.length > 1) {
        for (final w in matchingWallets) {
          if (text.contains(w.name.toLowerCase())) {
            selected = w;
            break;
          }
        }
      }

      '[AI_PARSING] 🎯 Matching existing investment wallet found: ${selected.name}'
          .Log('InvestmentFormController');
      selectInvestmentWallet(selected);
      pendingPrefillCategoryId.value = null;
      return;
    }

    // 2. Fallback to selecting the base category
    final category = _cachedCategories.firstWhereOrNull(
      (c) => c.id == categoryId,
    );
    if (category != null) {
      '[AI_PARSING] 🎯 Matching investment category found: ${category.id}'.Log(
        'InvestmentFormController',
      );
      selectInvestmentCategory(category);
      pendingPrefillCategoryId.value = null;
    }
  }

  /// Investment now supports category pre-filling via [applyQuickEntryCategory].
  @override
  bool get quickEntryShowsCategoryInLabel => true;

  @override
  void applyQuickEntryIntent(QuickEntryIntent intent, String text) {
    if (intent != QuickEntryIntent.investment) return;

    setDirection(
      QuickEntryIntentUtil.hasInvestmentReturn(text)
          ? InvestmentDirection.returnProfit
          : InvestmentDirection.contribute,
    );
  }

  @override
  final Rx<String?> pendingPrefillCategoryId = Rx<String?>(null);

  final RxList<int> quickAmounts = RxList<int>(
    MoneyConstants.budgetQuickAmounts,
  );

  @override
  void onTabActivated() {
    loadSuggestions();
  }

  Future<void> loadSuggestions() async {
    final settings = await _getProfileSettings();
    currencyCode.value = settings.currencyCode;
    final suggestions = MoneyConstants.getInvestmentSuggestions(
      settings.birthYear,
      currencyCode: currencyCode.value,
    );
    quickAmounts.assignAll(suggestions);
  }

  final Rx<InvestmentDirection> direction =
      InvestmentDirection.contribute.obs;
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  @override
  final RxInt categoryKey = 0.obs;
  final RxList<CategoryEntity> _cachedCategories = <CategoryEntity>[].obs;

  /// Merged list of existing investment assets (`WalletEntity`) and
  /// base investment categories (`CategoryEntity`).
  final RxList<dynamic> mergedItems = <dynamic>[].obs;
  final RxBool hasLoadingMerged = true.obs;

  /// Drives the asset row in `InvestmentAssetSelector` so the selected asset can
  /// be brought into view.
  final ScrollController assetRowScrollController = ScrollController();

  final Rx<String?> selectedInvestmentWalletId = Rx<String?>(null);

  final RxBool hasAddingNewItem = false.obs;
  final TextEditingController newItemNameController = TextEditingController();
  final RxString newItemName = ''.obs;

  /// The asset row is empty until the user creates their first investment
  /// item, so there is nothing a parsed quick entry could be saved into.
  @override
  bool get quickEntryHasSelectableCategory => mergedItems.isNotEmpty;

  @override
  List<String> get quickEntryAvailableCategoryIds {
    // In Investment, a category is only "available" for quick selection
    // if the user has already created an investment item (Wallet) for it.
    final List<String> ids = mergedItems
        .whereType<WalletEntity>()
        .map((wallet) => wallet.categoryId)
        .whereType<String>()
        .toList();

    return ids;
  }

  @override
  bool get canSubmit {
    final amount = amountStr.value;
    final walletId = selectedWalletId.value;
    final adding = hasAddingNewItem.value;
    final invWalletId = selectedInvestmentWalletId.value;
    final category = selectedCategory.value;
    final wallet = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
      (w) => w.id == invWalletId,
    );

    if (amount == '0' || amount.isEmpty) {
      return false;
    }
    if (walletId == null) {
      return false;
    }
    if (adding) {
      final ok = category != null && newItemName.value.trim().isNotEmpty;
      return ok;
    }
    if (invWalletId == null) {
      return false;
    }
    if (category != null) {
      return true;
    }
    if (wallet?.categoryId != null) {
      return true;
    }
    final investmentCats = _cachedCategories
        .where((c) => c.type == CategoryType.investment)
        .toList();
    final singleCat = investmentCats.length == 1;
    return singleCat;
  }

  @override
  void onInit() {
    super.onInit();
    _loadAll();
    final parentController = Get.find<TransactionController>();
    ever(parentController.wallets, (_) {
      _recomputeMergedItems();
    });

    ever(CategorySettingsController.onCategoriesChanged, (_) {
      _loadCategories();
      _recomputeMergedItems();
    });

    // Keep the selected asset card visible when the selection changes (tap,
    // quick entry, direction switch).
    everAll([selectedInvestmentWalletId, selectedCategory], (_) {
      _revealSelectedAsset();
    });
    quickEntry.initQuickEntry();
    ever(CurrencyConstants.onCurrencyChanged, (_) => loadSuggestions());
  }

  /// Centers the selected asset card in the asset row.
  void _revealSelectedAsset() {
    if (mergedItems.isEmpty) return;

    final walletId = selectedInvestmentWalletId.value;
    final categoryId = selectedCategory.value?.id;

    int index = -1;
    if (walletId != null) {
      index = mergedItems.indexWhere(
        (i) => i is WalletEntity && i.id == walletId,
      );
    }
    if (index == -1 && categoryId != null) {
      index = mergedItems.indexWhere(
        (i) => i is CategoryEntity && i.id == categoryId,
      );
    }
    if (index == -1) return;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => revealRowCard(
        scrollController: assetRowScrollController,
        index: index,
        itemWidth: assetCardWidth,
        itemGap: assetCardGap,
        leadingPadding: CcPaddingParams.PAGE_XS,
        tag: _debugTag,
      ),
    );
  }

  Future<void> _loadAll() async {
    hasLoadingMerged.value = true;
    final settings = await _getProfileSettings();
    quickEntry.hasVip.value = settings.hasVip;
    await loadSuggestions();
    await _loadCategories();
    await _recomputeMergedItems();
    hasLoadingMerged.value = false;
  }

  Future<void> _loadCategories() async {
    final result = await _getCategories();
    result.when((categories) {
      _cachedCategories.assignAll(categories);
    }, (error) {});
  }

  /// Refreshes the list of investment assets.
  /// Only shows existing investment wallets (synchronized with investment_list_page),
  /// not base categories from category_settings_page.
  Future<void> _recomputeMergedItems() async {
    final parentWallets = Get.find<TransactionController>().wallets;

    // Resolve categoryNameKey for wallets that have categoryId but
    // no categoryNameKey (common for wallets added via TransactionController
    // which does not resolve categoryNameKey on load).
    final categoryMap = {for (final c in _cachedCategories) c.id: c.nameKey};
    final resolvedWallets = [
      for (final w in parentWallets)
        if (w.type == WalletType.investment &&
            w.categoryId != null &&
            w.categoryNameKey == null)
          w.copyWith(categoryNameKey: categoryMap[w.categoryId])
        else
          w,
    ];

    // Deduplicate by ID to ensure consistency with investment_list_page logic
    // and avoid ghost items from stale sync states.
    final uniqueAssets = <String, WalletEntity>{};
    for (final w in resolvedWallets) {
      if (w.type == WalletType.investment) {
        uniqueAssets[w.id] = w;
      }
    }

    final assets = uniqueAssets.values.toList();

    assets.sort((a, b) {
      final timeCompare = b.updatedAt.compareTo(a.updatedAt);
      if (timeCompare != 0) return timeCompare;
      return a.displayOrder.compareTo(b.displayOrder);
    });

    // Deduplicate by resolved display name so that multiple wallets
    // mapping to the same name (e.g. "Cổ phiếu" and "Stock" both
    // resolving to "Stock" in English) are not shown as separate items.
    final seen = <String, WalletEntity>{};
    for (final w in assets) {
      final displayName = BudgetNameHelper.getDisplayName(
        name: w.name,
        categoryNameKey: w.categoryNameKey,
      );
      seen.putIfAbsent(displayName, () => w);
    }
    final deduped = seen.values.toList();

    // Only include investment wallets, not base categories
    // This ensures consistency with investment_list_page
    final List<dynamic> items = [...deduped];
    mergedItems.assignAll(items);

    if (selectedInvestmentWalletId.value == null &&
        selectedCategory.value == null &&
        mergedItems.isNotEmpty) {
      final first = mergedItems.first;
      if (first is WalletEntity) {
        selectInvestmentWallet(first);
      }
    } else if (selectedInvestmentWalletId.value != null &&
        selectedCategory.value == null) {
      final wallet = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
        (w) => w.id == selectedInvestmentWalletId.value,
      );
      if (wallet != null) {
        selectInvestmentWallet(wallet);
      } else {}
    }
  }

  void selectInvestmentWallet(WalletEntity wallet) {
    selectedInvestmentWalletId.value = wallet.id;
    hasAddingNewItem.value = false;

    final categories = _cachedCategories.toList();
    CategoryEntity? matched;
    if (wallet.categoryId != null) {
      matched = categories.firstWhereOrNull((c) => c.id == wallet.categoryId);
    }

    if (matched == null) {
      final investmentCats = categories
          .where((c) => c.type == CategoryType.investment)
          .toList();
      if (investmentCats.length == 1) {
        matched = investmentCats.first;
      }
    }

    if (matched != null) {
      selectedCategory.value = matched;
    } else {}
  }

  @override
  void selectInvestmentCategory(CategoryEntity category) {
    selectedCategory.value = category;
    selectedInvestmentWalletId.value = null;

    if (quickEntry.hasVip.value) {
      hasAddingNewItem.value = true;
      newItemName.value = el.tr(category.nameKey);
      newItemNameController.text = newItemName.value;
    } else {
      hasAddingNewItem.value = true;
      newItemName.value = el.tr(category.nameKey);
      newItemNameController.text = newItemName.value;
    }
  }

  @override
  void onClose() {
    newItemNameController.dispose();
    assetRowScrollController.dispose();
    quickEntry.disposeQuickEntry();
    super.onClose();
  }

  void setDirection(InvestmentDirection value) {
    if (direction.value == value) return;
    direction.value = value;
    _recomputeMergedItems();
    if (value == InvestmentDirection.returnProfit) {
      // Logic for return profit: must pick existing asset if available
      if (hasAddingNewItem.value || selectedInvestmentWalletId.value == null) {
        final firstAsset = mergedItems
            .whereType<WalletEntity>()
            .firstWhereOrNull((_) => true);
        if (firstAsset != null) {
          selectInvestmentWallet(firstAsset);
        } else {}
      }
    }
  }

  void setCategory(CategoryEntity category) {
    selectInvestmentCategory(category);
  }

  void selectInvestmentItem(String walletId) {
    final asset = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
      (w) => w.id == walletId,
    );
    if (asset != null) selectInvestmentWallet(asset);
  }

  @override
  void clearCategorySelection() {
    selectedCategory.value = null;
    selectedInvestmentWalletId.value = null;
    hasAddingNewItem.value = false;
  }

  void setNewItemName(String value) {
    newItemName.value = value;
  }

  @override
  String? composeNote() {
    final userNote = super.composeNote();
    final subsegment = direction.value == InvestmentDirection.contribute
        ? el.tr(PrjLocaleKeys.transaction_investment_contribution)
        : el.tr(PrjLocaleKeys.transaction_investment_return);

    if (userNote == null || userNote.isEmpty) return subsegment;
    return '$subsegment · $userNote';
  }

  @override
  Future<void> onReset() async {
    selectedCategory.value = null;
    categoryKey.value++;
    selectedInvestmentWalletId.value = null;
    hasAddingNewItem.value = false;
    newItemName.value = '';
    newItemNameController.clear();
    await _recomputeMergedItems();
    quickEntry.resetQuickEntry();
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (hasSubmitting.value || !canSubmit) {
      return;
    }
    hasSubmitting.value = true;

    CategoryEntity? category = selectedCategory.value;
    if (category == null && selectedInvestmentWalletId.value != null) {
      final wallet = mergedItems.whereType<WalletEntity>().firstWhereOrNull(
        (w) => w.id == selectedInvestmentWalletId.value,
      );
      if (wallet != null && wallet.categoryId != null) {
        final catResult = await _getCategories();
        category = catResult.tryGetSuccess()?.firstWhereOrNull(
          (c) => c.id == wallet.categoryId,
        );
      }
    }

    if (category == null) {
      hasSubmitting.value = false;
      if (context.mounted) {
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(PrjLocaleKeys.transaction_validation_category_required),
        );
      }
      return;
    }

    final params = CreateInvestmentTransactionParams(
      direction: direction.value,
      liquidWalletId: selectedWalletId.value,
      investmentWalletId: hasAddingNewItem.value
          ? null
          : selectedInvestmentWalletId.value,
      newItemName: hasAddingNewItem.value ? newItemName.value.trim() : null,
      categoryId: category.id,
      categoryLabel: el.tr(category.nameKey),
      categoryIconCode: category.iconCode,
      categoryIconFamily: category.iconFamily,
      amount: int.tryParse(amountStr.value) ?? 0,
      note: composeNote(),
      date: date.value,
    );

    final result = await _createInvestmentTransaction.call(params);
    hasSubmitting.value = false;

    result.when(
      (investmentWallet) async {
        final parentController = Get.find<TransactionController>();
        final now = DateTime.now();
        final updatedWallet = investmentWallet.copyWith(updatedAt: now);

        final idx = parentController.wallets.indexWhere(
          (w) => w.id == updatedWallet.id,
        );
        if (idx >= 0) {
          parentController.wallets[idx] = updatedWallet;
        } else {
          parentController.wallets.add(updatedWallet);
        }

        final settings = await _getProfileSettings();
        final amount = int.tryParse(amountStr.value) ?? 0;
        final savedAmount = MoneyFormatter.formatWithSymbol(
          amount,
          currencyCode: settings.currencyCode,
        );
        if (!context.mounted) return;
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            PrjLocaleKeys.transaction_investment_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );

        await resetForm();
        selectInvestmentWallet(updatedWallet);
        await refreshParent();

        // Complete the investment guideline task
        if (_guidelineProvider.hasAvailable) {
          _guidelineProvider.completeTask('investment');
        }
        if (context.mounted) {
          unawaited(getIt<GuestLoginPromptService>().maybeShow(context));
        }
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
