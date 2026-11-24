import 'package:cc_sdk/export_cc_sdk.dart';

import 'ai_prompts.dart';
import 'smart_entry_context.dart';

abstract final class SmartEntrySchema {
  static const String kindSingleReceipt = 'single_receipt';
  static const String kindTransactionList = 'transaction_list';
  static const String kindNotFinancial = 'not_financial';

  static CcAiSchema build(
    SmartEntryContext context, {
    required bool withDocumentKind,
    required int maxTransactions,
  }) {
    final properties = <String, CcAiSchema>{
      if (withDocumentKind)
        'documentKind': const CcAiSchema.enumString(
          enumValues: [
            kindSingleReceipt,
            kindTransactionList,
            kindNotFinancial,
          ],
          description: AiPrompts.fieldDocumentKind,
        ),
      'transactions': CcAiSchema.array(
        items: _item(context),
        maxItems: maxTransactions,
        description: AiPrompts.fieldTransactions(maxTransactions),
      ),
    };
    return CcAiSchema.object(
      properties: properties,
      propertyOrdering: properties.keys.toList(),
    );
  }

  static CcAiSchema _item(SmartEntryContext context) {
    final properties = <String, CcAiSchema>{
      if (context.hasMixed)
        'type': CcAiSchema.enumString(
          enumValues: context.types,
          description: AiPrompts.fieldType,
        ),
      'amount': CcAiSchema.number(
        description: AiPrompts.fieldAmount(context.currency),
        nullable: true,
        minimum: 0.01,
      ),
      'currencyCode': const CcAiSchema.string(
        description: AiPrompts.fieldCurrencyCode,
        nullable: true,
      ),
      'categoryId': CcAiSchema.enumString(
        enumValues: [for (final c in context.categories) c.id],
        description: AiPrompts.fieldCategoryId,
        nullable: true,
      ),
      if (context.wallets.isNotEmpty)
        'walletId': CcAiSchema.enumString(
          enumValues: [for (final w in context.wallets) w.id],
          description: AiPrompts.fieldWalletId,
          nullable: true,
        ),
      'date': const CcAiSchema.string(
        description: AiPrompts.fieldDate,
        nullable: true,
      ),
      'note': CcAiSchema.string(
        description: AiPrompts.fieldNote(context.language),
        nullable: true,
      ),
    };
    return CcAiSchema.object(
      properties: properties,
      propertyOrdering: properties.keys.toList(),
    );
  }
}
