import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/transaction_template_entity.dart';

abstract class TransactionTemplateRepository {
  Future<Result<List<TransactionTemplateEntity>, CcFailure>> getTemplates();

  Future<Result<void, CcFailure>> createTemplate(
    TransactionTemplateEntity template,
  );

  Future<Result<void, CcFailure>> deleteTemplate(String id);
}
