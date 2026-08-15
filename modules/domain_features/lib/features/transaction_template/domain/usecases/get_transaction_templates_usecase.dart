import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/transaction_template_entity.dart';
import '../repositories/transaction_template_repository.dart';

@lazySingleton
class GetTransactionTemplatesUseCase {
  GetTransactionTemplatesUseCase(this._repository);

  final TransactionTemplateRepository _repository;

  Future<Result<List<TransactionTemplateEntity>, CcFailure>> call() {
    return _repository.getTemplates();
  }
}
