import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Result<List<TransactionEntity>, CcFailure>> getListTransactions();

  Future<Result<List<TransactionEntity>, CcFailure>> getTransactions(
    PaginationRequest request,
  );
}
