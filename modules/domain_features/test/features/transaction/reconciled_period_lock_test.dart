import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_repository.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_entity.dart';
import 'package:domain_features/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/transaction/domain/services/reconciled_period_lock.dart';
import 'package:domain_features/features/transaction/domain/services/transaction_legs.dart';
import 'package:domain_features/features/transaction/domain/usecases/delete_transaction_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

class _Reconciliations implements ReconciliationRepository {
  _Reconciliations(this.latestDate);

  final DateTime? latestDate;

  @override
  Future<Result<ReconciliationEntity?, CcFailure>> getLatest() async => Success(
    latestDate == null
        ? null
        : ReconciliationEntity(
            id: 'r1',
            year: 2026,
            week: 48,
            systemTotal: 0,
            actualTotal: 0,
            difference: 0,
            allocations: const [],
            adjustmentTransactionIds: const [],
            date: latestDate!,
          ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionRepository {
  _Transactions([this.all = const []]);

  final List<TransactionEntity> all;
  final List<String> deleted = [];

  @override
  Future<Result<List<TransactionEntity>, CcFailure>>
  getListTransactions() async => Success(all);

  @override
  Future<Result<void, CcFailure>> softDeleteByIds(List<String> ids) async {
    deleted.addAll(ids);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TransactionEntity _tx(DateTime date) => TransactionEntity(
  id: 't1',
  type: TransactionType.expense,
  amount: 50000,
  category: 'Food',
  date: date,
  walletId: 'cash',
);

void main() {
  final reconciledAt = DateTime(2026, 11, 22, 20, 30);

  group('ReconciledPeriodLock.hasLocked', () {
    test('nothing reconciled: nothing is locked', () {
      expect(ReconciledPeriodLock.hasLocked(_tx(DateTime(2020)), null), false);
    });

    test('dated at or before the reconciliation: locked', () {
      final before = _tx(reconciledAt.subtract(const Duration(minutes: 1)));
      expect(ReconciledPeriodLock.hasLocked(before, reconciledAt), true);
      expect(
        ReconciledPeriodLock.hasLocked(_tx(reconciledAt), reconciledAt),
        true,
      );
    });

    test('dated after the reconciliation (same day too): editable', () {
      final after = _tx(reconciledAt.add(const Duration(minutes: 1)));
      expect(ReconciledPeriodLock.hasLocked(after, reconciledAt), false);
    });
  });

  group('DeleteTransactionUseCase', () {
    test('refuses a reconciled transaction and deletes nothing', () async {
      final transactions = _Transactions();
      final useCase = DeleteTransactionUseCase(
        transactions,
        TransactionLegs(
          transactions,
          CurrencyConversionService(_NoRates()),
          ReconciledPeriodLock(_Reconciliations(reconciledAt)),
        ),
      );

      final result = await useCase(_tx(DateTime(2026, 11, 20)));

      expect(
        result.tryGetError()?.message,
        PrjLocaleKeys.transaction_validation_reconciled,
      );
      expect(transactions.deleted, isEmpty);
    });

    test('deletes an unreconciled transaction', () async {
      final transactions = _Transactions();
      final useCase = DeleteTransactionUseCase(
        transactions,
        TransactionLegs(
          transactions,
          CurrencyConversionService(_NoRates()),
          ReconciledPeriodLock(_Reconciliations(reconciledAt)),
        ),
      );

      final result = await useCase(_tx(DateTime(2026, 11, 23)));

      expect(result.isSuccess(), true);
      expect(transactions.deleted, ['t1']);
    });
  });
  group('DeleteTransactionUseCase on a Chi ra pair', () {
    TransactionEntity leg(String id, String type, String wallet, DateTime d) =>
        TransactionEntity(
          id: id,
          type: type,
          amount: 6000000,
          category: 'Stocks',
          date: d,
          walletId: wallet,
          transferId: 'chi-ra-1',
          investmentWalletId: 'stock',
        );

    List<TransactionEntity> pair(DateTime d) => [
      leg('chi-ra-1_out', TransactionType.investmentOut, 'cash', d),
      leg('chi-ra-1_in', TransactionType.investmentIn, 'stock', d),
    ];

    DeleteTransactionUseCase useCase(_Transactions transactions) =>
        DeleteTransactionUseCase(
          transactions,
          TransactionLegs(
            transactions,
            CurrencyConversionService(_NoRates()),
            ReconciledPeriodLock(_Reconciliations(reconciledAt)),
          ),
        );

    test('deleting the cash leg soft-deletes both legs', () async {
      final legs = pair(DateTime(2026, 11, 23));
      final transactions = _Transactions(legs);

      final result = await useCase(transactions)(legs.first);

      expect(result.isSuccess(), true);
      expect(transactions.deleted, ['chi-ra-1_out', 'chi-ra-1_in']);
    });

    test('a reconciled pair is refused and nothing is deleted', () async {
      final legs = pair(DateTime(2026, 11, 20));
      final transactions = _Transactions(legs);

      final result = await useCase(transactions)(legs.first);

      expect(
        result.tryGetError()?.message,
        PrjLocaleKeys.transaction_validation_reconciled,
      );
      expect(transactions.deleted, isEmpty);
    });
  });
}

/// One currency everywhere, so no rate is ever looked up.
class _NoRates implements ExchangeRateRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
