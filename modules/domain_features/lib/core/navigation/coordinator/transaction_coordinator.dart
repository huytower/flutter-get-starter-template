import 'package:flutter/widgets.dart';

/// Contract for Transaction-related navigation.
abstract class TransactionCoordinator {
  /// Navigates back from transaction.
  void navigateBack(BuildContext context);
}
