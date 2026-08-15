import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/loan_entity.dart';

abstract class LoanRepository {
  Future<Result<List<LoanEntity>, CcFailure>> getLoans();

  Future<Result<LoanEntity, CcFailure>> getLoan(String id);

  Future<Result<void, CcFailure>> createLoan(LoanEntity loan);

  Future<Result<void, CcFailure>> updateLoan(LoanEntity loan);

  /// Only used to roll back a loan when its initiating transaction write
  /// fails (see `CreateLoanUseCase`) — this feature has no edit/delete UI.
  Future<Result<void, CcFailure>> deleteLoan(String id);
}
