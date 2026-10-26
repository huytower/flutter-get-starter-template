import 'dart:convert';

import '../../features/transaction/domain/entities/parsed_transaction_entity.dart';
import 'smart_entry_context.dart';
import 'smart_entry_schema.dart';

typedef RawParsedTransaction = ({
  ParsedTransactionEntity entity,
  String? foreignCurrencyCode,
  num? foreignAmount,
});

abstract final class SmartEntryResponseParser {
  static final RegExp _iso4217Pattern = RegExp(r'^[A-Z]{3}$');
  static final RegExp _jsonFencePattern = RegExp(r'```json|```');

  static List<RawParsedTransaction>? parse(
    String raw,
    SmartEntryContext context, {
    required int maxTransactions,
  }) {
    try {
      final decoded = jsonDecode(raw.replaceAll(_jsonFencePattern, '').trim());
      if (decoded is! Map) return null;
      final rows = decoded['transactions'];
      if (rows is! List) return null;
      if (decoded['documentKind'] == SmartEntrySchema.kindNotFinancial) {
        return const [];
      }

      final categoriesById = {for (final c in context.categories) c.id: c};
      final walletIds = {for (final w in context.wallets) w.id};
      final parsed = <RawParsedTransaction>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final item = _resolve(row, context, categoriesById, walletIds);
        if (item.entity.isEmpty && item.foreignAmount == null) continue;
        parsed.add(item);
        if (parsed.length == maxTransactions) break;
      }
      return parsed;
    } catch (_) {
      return null;
    }
  }

  static RawParsedTransaction _resolve(
    Map row,
    SmartEntryContext context,
    Map<String, AiPromptCategory> categoriesById,
    Set<String> walletIds,
  ) {
    final currencyValue = row['currencyCode'];
    final statedCode = currencyValue is String
        ? currencyValue.trim().toUpperCase()
        : null;
    final isForeign =
        statedCode != null &&
        _iso4217Pattern.hasMatch(statedCode) &&
        statedCode != context.currency.code;

    final amountValue = row['amount'];
    final positiveAmount = amountValue is num && amountValue > 0
        ? amountValue
        : null;
    final roundedAmount = positiveAmount?.round() ?? 0;
    final amount = !isForeign && roundedAmount > 0 ? roundedAmount : null;

    final typeValue = row['type'];
    final categoryValue = row['categoryId'];
    final category = categoryValue is String
        ? categoriesById[categoryValue]
        : null;
    final type = typeValue is String && context.types.contains(typeValue)
        ? typeValue
        : category?.type ?? context.defaultType;
    final categoryId = category != null && category.type == type
        ? category.id
        : null;

    final walletValue = row['walletId'];
    final walletId = walletValue is String && walletIds.contains(walletValue)
        ? walletValue
        : null;

    final dateValue = row['date'];
    DateTime? date;
    if (dateValue is String) {
      final parsed = DateTime.tryParse(dateValue);
      if (parsed != null && !parsed.isAfter(DateTime.now())) date = parsed;
    }

    final noteValue = row['note'];
    final note = noteValue is String && noteValue.trim().isNotEmpty
        ? noteValue.trim()
        : null;

    return (
      entity: ParsedTransactionEntity(
        type: context.isMixed ? type : null,
        amount: amount,
        categoryId: categoryId,
        walletId: walletId,
        date: date,
        note: note,
      ),
      foreignCurrencyCode: isForeign ? statedCode : null,
      foreignAmount: isForeign ? positiveAmount : null,
    );
  }
}
