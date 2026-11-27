import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_repository.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/transaction/domain/services/transaction_legs.dart';
import 'package:domain_features/features/transaction/domain/usecases/update_transaction_usecase.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../support/no_reconciliations.dart';

/// Simulation (BR §4.B): editing a Chi ra in the Report moves its mirror leg.
///
///   Cash 10,000,000 → Chi ra 6,000,000 into "Stocks"
///     cash leg  chi-ra-1_out  investmentOut  6,000,000  (cash balance)
///     stock leg chi-ra-1_in   investmentIn   6,000,000  (contributed, ROI)
///   Edit the cash leg to 5,000,000 → both legs become 5,000,000.

class _Transactions implements TransactionRepository {
  _Transactions(this.all);

  final List<TransactionEntity> all;
  final Map<String, TransactionEntity> saved = {};

  @override
  Future<Result<List<TransactionEntity>, CcFailure>>
  getListTransactions() async => Success(all);

  @override
  Future<Result<void, CcFailure>> updateTransaction(TransactionEntity t) async {
    saved[t.id] = t;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Wallets implements WalletRepository {
  @override
  Future<Result<WalletEntity, CcFailure>> getWallet(String id) async => Success(
    WalletEntity(
      id: id,
      name: id,
      balance: 10000000,
      iconCode: 0,
      type: WalletType.cash,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Only expenses check the balance; a Chi ra never calls it.
class _UnusedBalance implements GetWalletBookBalanceUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRates implements ExchangeRateRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TransactionEntity _leg(String id, String type, String wallet, DateTime d) =>
    TransactionEntity(
      id: id,
      type: type,
      amount: 6000000,
      category: 'Stocks',
      categoryId: 'stocks',
      date: d,
      walletId: wallet,
      transferId: 'chi-ra-1',
      investmentWalletId: 'stock',
    );

void main() {
  test(
    'editing the cash leg rewrites the mirror leg and keeps the position link',
    () async {
      final date = DateTime.now().subtract(const Duration(days: 1));
      final out = _leg(
        'chi-ra-1_out',
        TransactionType.investmentOut,
        'cash',
        date,
      );
      final inLeg = _leg(
        'chi-ra-1_in',
        TransactionType.investmentIn,
        'stock',
        date,
      );
      final transactions = _Transactions([out, inLeg]);
      final conversion = CurrencyConversionService(_NoRates());
      final useCase = UpdateTransactionUseCase(
        transactions,
        _Wallets(),
        _UnusedBalance(),
        conversion,
        TransactionLegs(transactions, conversion, noReconciliationLock()),
      );

      final result = await useCase(
        UpdateTransactionParams(
          original: out,
          amount: 5000000,
          categoryId: 'stocks',
          categoryLabel: 'Stocks',
          walletId: 'cash',
          note: 'corrected',
          date: date,
        ),
      );

      expect(result.isSuccess(), isTrue);
      final cashLeg = transactions.saved['chi-ra-1_out']!;
      final stockLeg = transactions.saved['chi-ra-1_in']!;
      expect(cashLeg.amount, 5000000);
      expect(stockLeg.amount, 5000000, reason: 'mirror leg follows');
      expect(stockLeg.walletId, 'stock');
      expect(stockLeg.note, 'corrected');
      expect(
        cashLeg.investmentWalletId,
        'stock',
        reason: 'the edit keeps the link to the position (ROI, delete cascade)',
      );
    },
  );
}
