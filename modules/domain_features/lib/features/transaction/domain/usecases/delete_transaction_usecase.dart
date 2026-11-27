import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/transaction_repository.dart';
import '../services/transaction_legs.dart';

/// Deletes (soft) a transaction the user picked, together with its mirror leg
/// when it is a Chi ra ([TransactionLegs]), unless any leg is already part of
/// a reconciliation.
///
/// For user deletes only: system flows that must remove their own records
/// (reconciliation undo, rollback of a half-written transfer) call the
/// repository directly.
@injectable
class DeleteTransactionUseCase {
  DeleteTransactionUseCase(this._transactionRepository, this._legs);

  final TransactionRepository _transactionRepository;
  final TransactionLegs _legs;

  static const _tag = 'DeleteTransaction';

  Future<Result<void, CcFailure>> call(TransactionEntity transaction) async {
    final legs = await _legs.legsOf(transaction);
    await _legs.trace(_tag, legs);
    if (await _legs.hasReconciled(legs)) {
      '[$_tag] refused: a leg is reconciled'.Log(_tag);
      return const Error(
        CcValidationFailure(PrjLocaleKeys.transaction_validation_reconciled),
      );
    }
    final ids = [for (final t in legs) t.id];
    '[$_tag] soft-deleting $ids'.Log(_tag);
    return _transactionRepository.softDeleteByIds(ids);
  }
}
