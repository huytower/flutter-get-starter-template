import 'package:flutter/widgets.dart';

import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';

/// Contract for Transaction-related navigation.
abstract class TransactionCoordinator {
  /// Navigates back from transaction.
  void navigateBack(BuildContext context);

  /// Navigates to a specific transaction detail.
  void navigateToTransactionDetail(BuildContext context, TransactionEntity transaction);
}
