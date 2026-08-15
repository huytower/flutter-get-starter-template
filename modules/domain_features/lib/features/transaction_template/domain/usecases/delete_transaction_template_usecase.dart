import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/transaction_template_repository.dart';

@lazySingleton
class DeleteTransactionTemplateUseCase {
  DeleteTransactionTemplateUseCase(this._repository);

  final TransactionTemplateRepository _repository;

  Future<Result<void, CcFailure>> call(String id) {
    return _repository.deleteTemplate(id);
  }
}
