import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

import '../../../report/presentation/widgets/quick_edit_transaction_sheet.dart';

/// Bottom sheet for correcting a previously recorded transaction. Delegates to
/// [QuickEditTransactionSheet] to provide a compact, fitted bottom-sheet UX/UI.
class EditTransactionSheet {
  const EditTransactionSheet._();

  static Future<void> show(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    return QuickEditTransactionSheet.show(context, transaction);
  }
}
