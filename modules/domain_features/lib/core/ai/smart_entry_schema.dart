import 'package:cc_sdk/export_cc_sdk.dart';

import 'ai_prompts.dart';
import 'smart_entry_context.dart';

abstract final class SmartEntrySchema {
  static const String kindSingleReceipt = 'single_receipt';
  static const String kindTransactionList = 'transaction_list';
  static const String kindNotFinancial = 'not_financial';

  static Schema build(
    SmartEntryContext context, {
    required bool withDocumentKind,
    required int maxTransactions,
  }) {
    final properties = <String, Schema>{
      if (withDocumentKind)
        'documentKind': Schema.enumString(
          enumValues: const [
            kindSingleReceipt,
            kindTransactionList,
            kindNotFinancial,
          ],
          description: AiPrompts.fieldDocumentKind,
        ),
      'transactions': Schema.array(
        items: _item(context),
        maxItems: maxTransactions,
        description: AiPrompts.fieldTransactions(maxTransactions),
      ),
    };
    return Schema.object(
      properties: properties,
      propertyOrdering: properties.keys.toList(),
    );
  }

  static Schema _item(SmartEntryContext context) {
    final properties = <String, Schema>{
      if (context.isMixed)
        'type': Schema.enumString(
          enumValues: context.types,
          description: AiPrompts.fieldType,
        ),
      'amount': Schema.number(
        description: AiPrompts.fieldAmount(context.currency),
        nullable: true,
        minimum: 0.01,
      ),
      'currencyCode': Schema.string(
        description: AiPrompts.fieldCurrencyCode,
        nullable: true,
      ),
      'categoryId': Schema.enumString(
        enumValues: [for (final c in context.categories) c.id],
        description: AiPrompts.fieldCategoryId,
        nullable: true,
      ),
      if (context.wallets.isNotEmpty)
        'walletId': Schema.enumString(
          enumValues: [for (final w in context.wallets) w.id],
          description: AiPrompts.fieldWalletId,
          nullable: true,
        ),
      'date': Schema.string(description: AiPrompts.fieldDate, nullable: true),
      'note': Schema.string(
        description: AiPrompts.fieldNote(context.language),
        nullable: true,
      ),
    };
    return Schema.object(
      properties: properties,
      propertyOrdering: properties.keys.toList(),
    );
  }
}
