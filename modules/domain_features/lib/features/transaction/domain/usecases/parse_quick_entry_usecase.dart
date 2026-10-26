import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';

import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

@lazySingleton
class ParseQuickEntryUseCase {
  ParseQuickEntryUseCase(this._getCategories);

  final GetCategoriesUseCase _getCategories;
  WalletRepository get _walletRepository => getIt<WalletRepository>();

  Future<List<CategoryEntity>> _loadCategories(
    String categoryType,
    List<String>? groupIds,
  ) async {
    final result = await _getCategories.call();
    return result
            .tryGetSuccess()
            ?.where(
              (c) =>
                  c.isEnabled &&
                  c.type == categoryType &&
                  (groupIds == null || groupIds.contains(c.groupId)),
            )
            .toList() ??
        const <CategoryEntity>[];
  }

  Future<ParsedTransactionEntity> parseLocally(
    String text, {
    String categoryType = CategoryType.expense,
    List<String>? groupIds,
  }) async {
    final categories = await _loadCategories(categoryType, groupIds);
    final walletsResult = await _walletRepository.getWallets();
    final wallets = walletsResult.tryGetSuccess();

    return parseQuickEntryTextLocally(
      text: text,
      categories: categories,
      categoryLabels: (c) => el.tr(c.nameKey),
      wallets: wallets,
    );
  }
}
