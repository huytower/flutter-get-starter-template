import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart';
import 'package:domain_features/features/transaction/domain/entities/investment_direction.dart';
import 'package:domain_features/features/transaction/domain/usecases/create_investment_transaction_usecase.dart';
import 'package:domain_features/features/transaction/presentation/get_x/investment_form_controller.dart';
import 'package:domain_features/features/transaction/presentation/get_x/quick_entry_handler.dart';
import 'package:domain_features/features/transaction/presentation/get_x/transaction_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Categories implements GetCategoriesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Settings implements GetProfileSettingsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Create implements CreateInvestmentTransactionUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Guideline implements GuidelineProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _QuickEntry implements QuickEntryHandler {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The form only reads the screen's wallet list from its parent.
class _Parent extends GetxController implements TransactionController {
  @override
  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WalletEntity _wallet(String id, String type) => WalletEntity(
  id: id,
  name: id,
  balance: 0,
  iconCode: 0,
  type: type,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _Parent parent;
  late InvestmentFormController form;

  final cash = _wallet('cash', WalletType.cash);
  final gold = _wallet('gold', WalletType.investment);
  final stock = _wallet('stock', WalletType.investment);

  setUp(() {
    parent = _Parent();
    Get.put<TransactionController>(parent);
    form = InvestmentFormController(
      _Categories(),
      _Settings(),
      _Create(),
      _Guideline(),
      _QuickEntry(),
    );
    parent.wallets.assignAll([cash, gold, stock]);
    form.selectInvestmentWallet(gold);
    form.selectedCategory.value = const CategoryEntity(
      id: 'c',
      groupId: 'g',
      nameKey: 'c',
      iconCode: 0,
      iconFamily: 'MaterialIcons',
      type: CategoryType.investment,
    );
  });

  tearDown(Get.reset);

  /// Switching direction rebuilds the asset row, as a wallet change does.
  void rebuildAssets() {
    form.setDirection(InvestmentDirection.returnProfit);
    form.setDirection(InvestmentDirection.contribute);
  }

  test('deleting the selected position moves the selection on', () {
    parent.wallets.removeWhere((w) => w.id == 'gold');
    rebuildAssets();

    expect(form.selectedInvestmentWalletId.value, 'stock');
  });

  test('deleting the last position clears the selection', () {
    parent.wallets.assignAll([cash]);
    rebuildAssets();

    expect(form.selectedInvestmentWalletId.value, isNull);
    expect(form.selectedCategory.value, isNull);
  });

  test('a list being reloaded keeps the selection', () {
    parent.wallets.clear();
    rebuildAssets();

    expect(form.selectedInvestmentWalletId.value, 'gold');
  });
}
