import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/entities/loan_balance_entity.dart';
import '../../domain/usecases/get_loan_balances_usecase.dart';

@injectable
class LoanListController extends CcGetController {
  LoanListController(this._getLoanBalances);

  final GetLoanBalancesUseCase _getLoanBalances;

  final RxList<LoanBalanceEntity> loans = <LoanBalanceEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    layoutStatus.value = CcLayoutStatus.loading;
    final result = await _getLoanBalances();
    result.when(
      (balances) {
        loans.assignAll(balances);
        layoutStatus.value = CcLayoutStatus.success;
      },
      (_) {
        layoutStatus.value = CcLayoutStatus.error;
      },
    );
  }
}
