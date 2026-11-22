import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;

import '../../../../core/currency/money_formatter.dart';
import '../../../../core/domain/entities/category_entity.dart';
import '../../domain/entities/parsed_transaction_entity.dart';
import 'quick_entry_parser.dart';
import 'transaction_form_controller.dart';

/// The categories a quick entry may resolve to in one form: loads and caches
/// them, labels a parsed result, and says whether its category is usable.
class QuickEntryCategoryCache {
  QuickEntryCategoryCache(this._form, this._parser);

  final TransactionFormController _form;
  final QuickEntryParser _parser;

  List<CategoryEntity> _categories = [];

  bool get isEmpty => _categories.isEmpty;

  /// Ids of the cached categories; the default for
  /// [TransactionFormController.quickEntryAvailableCategoryIds].
  List<String> get ids => _categories.map((category) => category.id).toList();

  /// Reloads the cache. Call again whenever the form's
  /// [TransactionFormController.quickEntryCategoryGroupIds] change at runtime
  /// (e.g. Loan switching direction), or labels go stale.
  Future<void> refresh() async {
    final result = await _parser.loadCategories();
    final groupIds = _form.quickEntryCategoryGroupIds;
    _categories =
        result
            .tryGetSuccess()
            ?.where(
              (category) =>
                  category.isEnabled &&
                  category.type == _form.quickEntryCategoryType &&
                  (groupIds == null || groupIds.contains(category.groupId)),
            )
            .toList() ??
        [];
  }

  CategoryEntity? find(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// Display label for a suggestion, e.g. "50.00k · Cà phê · 12/08" — lists
  /// only whatever actually resolved.
  String labelFor(ParsedTransactionEntity result) {
    final parts = <String>[];
    if (result.amount != null) {
      parts.add(formatShortCurrencyWithSymbol(result.amount!));
    }
    if (result.categoryId != null && _form.quickEntryShowsCategoryInLabel) {
      final category = find(result.categoryId!);
      if (category != null) parts.add(el.tr(category.nameKey));
    }
    if (result.date != null) {
      parts.add(el.DateFormat('dd/MM').format(result.date!));
    }
    if (parts.isEmpty && result.note != null) {
      parts.add(result.note!);
    }
    return parts.join(' · ');
  }

  /// Whether [result]'s category is unusable in this form — never resolved,
  /// or resolved to an id this form can't record against.
  bool isMissingFor(ParsedTransactionEntity result) {
    // Nothing to record against at all, whatever the parse resolved.
    if (!_form.quickEntryHasSelectableCategory) return true;

    final id = result.categoryId;
    if (id == null) return true;

    final availableIds = _form.quickEntryAvailableCategoryIds;
    final isAvailable = availableIds.contains(id);
    '[AI_PARSING] 🔍 Checking category missing | id=$id | isAvailable=$isAvailable | availableCount=${availableIds.length}'
        .Log('QuickEntryCategoryCache');
    return !isAvailable;
  }
}
