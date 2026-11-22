import 'package:cc_bridge/export_cc_bridge.dart'
    show AuthCoordinator, SessionContract;
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/user_level_status_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_repository.dart';
import 'package:domain_features/features/category/domain/repositories/category_repository.dart';
import 'package:domain_features/features/firestore/guest_login_prompt_service.dart';
import 'package:domain_features/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:domain_features/features/profile/domain/repositories/profile_repository.dart';
import 'package:domain_features/features/profile/domain/usecases/get_profile_settings_usecase.dart';
import 'package:domain_features/features/profile/domain/usecases/update_profile_settings_usecase.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/services/emergency_fund_access.dart';
import 'package:domain_features/features/wallet/domain/services/wallet_ledger.dart';
import 'package:domain_features/features/wallet/domain/usecases/load_wallet_overview_usecase.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_change_effects.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

// Simulates the wallet screens end to end on in-memory storage: load, add,
// edit, guard rules, delete, and what other features are told. Only storage
// and the cross-feature contracts are fakes; every wallet class is real.

final _epoch = DateTime.utc(2026);

WalletEntity _wallet(String id, String type, {int balance = 0}) => WalletEntity(
  id: id,
  name: id,
  balance: balance,
  iconCode: 0,
  type: type,
  createdAt: _epoch,
  updatedAt: _epoch,
);

TransactionEntity _txn(String id, String type, int amount, String walletId) =>
    TransactionEntity(
      id: id,
      type: type,
      amount: amount,
      category: '',
      date: DateTime.now(),
      walletId: walletId,
    );

class _Wallets implements WalletRepository {
  final Map<String, WalletEntity> store = {};

  @override
  Future<Result<List<WalletEntity>, CcFailure>> getWallets() async =>
      Success(store.values.toList());

  @override
  Future<Result<void, CcFailure>> addWallet(WalletEntity wallet) async {
    store[wallet.id] = wallet;
    return const Success(null);
  }

  @override
  Future<Result<void, CcFailure>> updateWallet(WalletEntity wallet) async {
    store[wallet.id] = wallet;
    return const Success(null);
  }

  @override
  Future<Result<void, CcFailure>> deleteWallet(String id) async {
    store.remove(id);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionRepository {
  final List<TransactionEntity> all = [];

  @override
  Future<Result<List<TransactionEntity>, CcFailure>>
  getListTransactions() async => Success(List.of(all));

  @override
  Future<Result<void, CcFailure>> softDeleteByWallet(String walletId) async {
    all.removeWhere((t) => t.walletId == walletId);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Categories implements CategoryRepository {
  @override
  Future<Result<List<CategoryEntity>, CcFailure>> getCategories() async =>
      const Success([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Profile implements ProfileRepository {
  ProfileSettingsEntity settings = const ProfileSettingsEntity();

  @override
  Future<ProfileSettingsEntity> getSettings() async => settings;

  @override
  Future<void> saveSettings(ProfileSettingsEntity value) async =>
      settings = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRates implements ExchangeRateRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UserLevel implements UserLevelProvider {
  int level = 1;

  @override
  UserLevelStatusEntity get status => UserLevelStatusEntity(
    level: level,
    reconciliationStreak: 0,
    hasMinBudgets: false,
    hasPositiveCashFlow: false,
    fixedBudgetCount: 0,
    completedGuidelineCount: 0,
    isVip: false,
  );

  @override
  Future<void> refresh() async {}
}

/// Records what the wallet screens tell other features.
class _Refresh implements FinancialRefreshProvider {
  final List<String> events = [];

  @override
  void addWalletToTransactions(WalletEntity wallet) =>
      events.add('added ${wallet.id}');

  @override
  void updateWalletInTransactions(WalletEntity wallet) =>
      events.add('updated ${wallet.id}');

  @override
  void removeWalletFromTransactions(String walletId) =>
      events.add('removed $walletId');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Guideline implements GuidelineProvider {
  final List<String> completed = [];

  @override
  Future<void> completeTask(String taskId) async => completed.add(taskId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Unused implements SessionContract, AuthCoordinator {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Wallets wallets;
  late _Transactions transactions;
  late _Profile profile;
  late _UserLevel userLevel;
  late _Refresh refresh;
  late _Guideline guideline;
  late WalletController controller;

  setUp(() {
    wallets = _Wallets()
      ..store['cash'] = _wallet('cash', WalletType.cash, balance: 100);
    transactions = _Transactions();
    profile = _Profile();
    userLevel = _UserLevel();
    refresh = _Refresh();
    guideline = _Guideline();
    final getSettings = GetProfileSettingsUseCase(profile);
    controller = WalletController(
      wallets,
      LoadWalletOverviewUseCase(wallets, _Categories(), getSettings),
      WalletLedger(transactions, CurrencyConversionService(_NoRates())),
      EmergencyFundAccess(
        userLevel,
        getSettings,
        UpdateProfileSettingsUseCase(profile),
      ),
      WalletChangeEffects(
        refresh,
        guideline,
        GuestLoginPromptService(_Unused(), _Unused()),
      ),
    );
  });

  test('load derives book balances and totals from transactions', () async {
    transactions.all
      ..add(_txn('t1', TransactionType.income, 50, 'cash'))
      ..add(_txn('t2', TransactionType.expense, 30, 'cash'));

    await controller.loadWallets();

    expect(controller.bookBalanceOf('cash'), 120);
    expect(controller.totalBalance.value, 120);
    expect(controller.liquidBalance.value, 120);
    expect(controller.walletHasTransactions('cash'), isTrue);
  });

  test(
    'add: stored, counted in the totals, sent to the transaction picker',
    () async {
      await controller.loadWallets();

      await controller.addWallet(
        name: 'Bank',
        initialBalance: 400,
        iconCode: 0,
        type: WalletType.bank,
      );

      expect(controller.errorMessage.value, isEmpty);
      expect(wallets.store, hasLength(2));
      final added = controller.wallets.firstWhere((w) => w.name == 'Bank');
      expect(controller.bookBalanceOf(added.id), 400);
      expect(controller.totalBalance.value, 500);
      expect(refresh.events, ['added ${added.id}']);
    },
  );

  test('emergency fund stays locked until level 3 and the ebook', () async {
    await controller.loadWallets();
    userLevel.level = 3;

    await controller.addWallet(
      name: 'Rainy',
      initialBalance: 10,
      iconCode: 0,
      type: WalletType.emergencyFund,
    );
    expect(wallets.store, hasLength(1), reason: 'locked: nothing stored');
    expect(controller.errorMessage.value, isNotEmpty);

    profile.settings = profile.settings.copyWith(
      hasViewedEmergencyFundEbook: true,
    );
    controller.errorMessage.value = '';
    await controller.addWallet(
      name: 'Rainy',
      initialBalance: 10,
      iconCode: 0,
      type: WalletType.emergencyFund,
    );
    expect(wallets.store, hasLength(2));
    expect(controller.emergencyFundBalance.value, 10);
  });

  test('edit keeps the opening balance once the wallet has activity', () async {
    transactions.all.add(_txn('t1', TransactionType.income, 50, 'cash'));
    await controller.loadWallets();

    final cash = controller.wallets.single;
    await controller.updateWallet(cash.copyWith(name: 'Pocket', balance: 999));

    expect(wallets.store['cash']!.balance, 100, reason: 'opening kept');
    expect(wallets.store['cash']!.name, 'Pocket');
    expect(controller.bookBalanceOf('cash'), 150);
    expect(refresh.events, ['updated cash']);
    expect(guideline.completed, contains(WalletChangeEffects.balanceTask));
  });

  test('edit of an untouched wallet changes its opening balance', () async {
    await controller.addWallet(
      name: 'Bank',
      initialBalance: 400,
      iconCode: 0,
      type: WalletType.bank,
    );
    final bank = controller.wallets.firstWhere((w) => w.name == 'Bank');

    await controller.updateWallet(bank.copyWith(balance: 250));

    expect(wallets.store[bank.id]!.balance, 250);
    expect(controller.bookBalanceOf(bank.id), 250);
  });

  test('delete rules: Cash is protected, a used wallet is not empty', () async {
    await controller.addWallet(
      name: 'Bank',
      initialBalance: 0,
      iconCode: 0,
      type: WalletType.bank,
    );
    final bank = controller.wallets.firstWhere((w) => w.name == 'Bank');
    transactions.all.add(_txn('t1', TransactionType.expense, 5, bank.id));
    controller.markDirty();
    await controller.loadWallets();

    expect(
      await controller.deleteWallet('cash'),
      WalletDeleteOutcome.protected,
    );
    expect(
      await controller.deleteWallet(bank.id),
      WalletDeleteOutcome.notEmpty,
    );
    expect(wallets.store, contains(bank.id));
    expect(await controller.deleteWallet('missing'), WalletDeleteOutcome.error);
  });

  test('delete of an empty wallet removes it everywhere', () async {
    await controller.loadWallets();
    await controller.addWallet(
      name: 'Bank',
      initialBalance: 0,
      iconCode: 0,
      type: WalletType.bank,
    );
    final bank = controller.wallets.firstWhere((w) => w.name == 'Bank');
    refresh.events.clear();

    expect(await controller.deleteWallet(bank.id), WalletDeleteOutcome.success);

    expect(wallets.store.keys, ['cash']);
    expect(controller.wallets.map((w) => w.id), ['cash']);
    expect(controller.totalBalance.value, 100);
    expect(refresh.events, ['removed ${bank.id}']);
  });

  test('an investment wallet with history can be deleted with it', () async {
    final fund = _wallet('fund', WalletType.investment);
    wallets.store['fund'] = fund;
    transactions.all.add(_txn('t1', TransactionType.investmentIn, 70, 'fund'));
    await controller.loadWallets();

    expect(await controller.deleteWallet('fund'), WalletDeleteOutcome.success);
    expect(transactions.all, isEmpty, reason: 'its transactions go too');
  });

  test(
    'a markDirty during a running load is picked up by the follow-up',
    () async {
      await controller.loadWallets();
      final first = controller.loadWallets(forceRefresh: true);
      transactions.all.add(_txn('t1', TransactionType.income, 25, 'cash'));
      controller.markDirty();
      final second = controller.loadWallets();
      await Future.wait([first, second]);

      expect(controller.bookBalanceOf('cash'), 125);
    },
  );
}
