import 'package:auto_route/auto_route.dart';
import 'package:domain_features/core/navigation/coordinator/transaction_coordinator.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TransactionCoordinator)
class TransactionCoordinatorImpl implements TransactionCoordinator {
  @override
  void navigateBack(BuildContext context) {
    context.router.back();
  }
}
