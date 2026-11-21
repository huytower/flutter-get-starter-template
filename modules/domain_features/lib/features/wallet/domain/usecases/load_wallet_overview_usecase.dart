import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:collection/collection.dart';
import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/category/domain/repositories/category_repository.dart';
import 'package:domain_features/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

/// What the wallet screens show on load: the user's settings (VIP, currency)
/// and every wallet, labelled with its investment category.
typedef WalletOverview = ({
  ProfileSettingsEntity settings,
  List<WalletEntity> wallets,
});

/// Loads the [WalletOverview]. Categories that fail to load only leave the
/// labels empty; a wallet failure is returned as the error.
@injectable
class LoadWalletOverviewUseCase {
  LoadWalletOverviewUseCase(this._wallets, this._categories, this._getSettings);

  final WalletRepository _wallets;
  final CategoryRepository _categories;
  final GetProfileSettingsUseCase _getSettings;

  Future<Result<WalletOverview, CcFailure>> call() async {
    final settings = await _getSettings();

    final result = await _wallets.getWallets();
    if (result.isError()) return Error(result.tryGetError()!);

    final catResult = await _categories.getCategories();
    final categories = catResult.tryGetSuccess() ?? <CategoryEntity>[];

    final wallets = [
      for (final wallet in result.tryGetSuccess()!)
        wallet.categoryId == null
            ? wallet
            : wallet.copyWith(
                categoryNameKey: categories
                    .firstWhereOrNull((c) => c.id == wallet.categoryId)
                    ?.nameKey,
              ),
    ];
    return Success((settings: settings, wallets: wallets));
  }
}
