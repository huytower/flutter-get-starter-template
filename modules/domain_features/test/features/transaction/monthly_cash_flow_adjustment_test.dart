import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/transaction/domain/usecases/get_monthly_cash_flow_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

/// BR §6: reconciliation adjustments are ordinary income/expense entries, so
/// the deficit warning (and the LV3 cash-flow check built the same way) count
/// them like any other entry of the month.
class _Transactions implements TransactionRepository {
  _Transactions(this.items);

  final List<TransactionEntity> items;

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  ) async => Success(items);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TransactionEntity _tx(String id, String type, int amount, String category) =>
    TransactionEntity(
      id: id,
      type: type,
      amount: amount,
      category: category,
      date: DateTime.now(),
      walletId: 'cash',
    );

void main() {
  test(
    'a shortfall adjustment counts as expense in the deficit check',
    () async {
      final cashFlow = (await GetMonthlyCashFlowUseCase(
        _Transactions([
          _tx('salary', TransactionType.income, 1000000, 'Salary'),
          _tx('food', TransactionType.expense, 600000, 'Food'),
          _tx('adj', TransactionType.expense, 500000, 'Điều chỉnh khớp sổ'),
        ]),
      ).call()).tryGetSuccess()!;

      expect(cashFlow.expense, 1100000);
      expect(cashFlow.hasDeficit, isTrue);
    },
  );

  test('a surplus adjustment counts as income', () async {
    final cashFlow = (await GetMonthlyCashFlowUseCase(
      _Transactions([
        _tx('food', TransactionType.expense, 600000, 'Food'),
        _tx('adj', TransactionType.income, 700000, 'Điều chỉnh khớp sổ'),
      ]),
    ).call()).tryGetSuccess()!;

    expect(cashFlow.income, 700000);
    expect(cashFlow.hasDeficit, isFalse);
  });
}
