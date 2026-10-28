import 'package:get/get.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/entities/parsed_transaction_entity.dart';

class SmartEntryPreviewRow {
  const SmartEntryPreviewRow({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.walletId,
    required this.date,
    required this.note,
  });

  final int id;
  final String type;
  final int amount;
  final String categoryId;
  final String walletId;
  final DateTime date;
  final String note;

  SmartEntryPreviewRow copyWith({
    String? type,
    int? amount,
    String? categoryId,
    String? walletId,
    DateTime? date,
    String? note,
  }) {
    return SmartEntryPreviewRow(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

class SmartEntryPreviewConfig {
  const SmartEntryPreviewConfig({
    required this.types,
    required this.currencyCode,
    this.showCategory = true,
    this.appliesToForm = false,
  });

  final List<String> types;
  final String currencyCode;
  final bool showCategory;
  final bool appliesToForm;

  bool get showType => types.length > 1;
}

class SmartEntryCommitResult {
  const SmartEntryCommitResult({required this.saved, this.error});

  final int saved;
  final String? error;
}

typedef SmartEntryCommit =
    Future<SmartEntryCommitResult> Function(List<ParsedTransactionEntity> rows);

class SmartEntryPreviewState {
  SmartEntryPreviewState({
    required List<ParsedTransactionEntity> parsed,
    required this.categories,
    required this.wallets,
    required this.config,
    required String defaultWalletId,
    DateTime? now,
  }) : _now = now ?? DateTime.now() {
    rows.assignAll([for (final item in parsed) _toRow(item, defaultWalletId)]);
  }

  final List<CategoryEntity> categories;
  final List<WalletEntity> wallets;
  final SmartEntryPreviewConfig config;
  final DateTime _now;

  final RxList<SmartEntryPreviewRow> rows = <SmartEntryPreviewRow>[].obs;
  final RxBool isCommitting = false.obs;
  final Rx<String?> errorText = Rx<String?>(null);

  int _nextId = 0;

  SmartEntryPreviewRow _toRow(
    ParsedTransactionEntity item,
    String defaultWalletId,
  ) {
    final type = config.showType && config.types.contains(item.type)
        ? item.type!
        : config.types.first;
    final date = item.date;
    return SmartEntryPreviewRow(
      id: _nextId++,
      type: type,
      amount: item.amount ?? 0,
      categoryId: _validCategoryId(item.categoryId, type),
      walletId: _validWalletId(item.walletId) ?? defaultWalletId,
      date: date == null
          ? _now
          : DateTime(date.year, date.month, date.day, _now.hour, _now.minute),
      note: item.note ?? '',
    );
  }

  String _validCategoryId(String? id, String type) {
    if (id == null) return '';
    final category = categoryById(id);
    return category != null && category.type == type ? id : '';
  }

  String? _validWalletId(String? id) => walletById(id) != null ? id : null;

  CategoryEntity? categoryById(String? id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  WalletEntity? walletById(String? id) {
    for (final wallet in wallets) {
      if (wallet.id == id) return wallet;
    }
    return null;
  }

  List<CategoryEntity> categoriesFor(String type) => [
    for (final category in categories)
      if (category.type == type) category,
  ];

  void edit(
    int id,
    SmartEntryPreviewRow Function(SmartEntryPreviewRow) change,
  ) {
    final index = rows.indexWhere((row) => row.id == id);
    if (index == -1) return;
    rows[index] = change(rows[index]);
    errorText.value = null;
  }

  void setType(int id, String type) {
    edit(id, (row) {
      if (row.type == type) return row;
      final category = categoryById(row.categoryId);
      final keep = category != null && category.type == type;
      return row.copyWith(type: type, categoryId: keep ? row.categoryId : '');
    });
  }

  void remove(int id) {
    rows.removeWhere((row) => row.id == id);
    errorText.value = null;
  }

  void dropSaved(int count) {
    if (count <= 0) return;
    rows.removeRange(0, count.clamp(0, rows.length));
  }

  bool isValid(SmartEntryPreviewRow row) =>
      row.amount > 0 &&
      row.walletId.isNotEmpty &&
      (!config.showCategory || row.categoryId.isNotEmpty);

  bool get canConfirm =>
      rows.isNotEmpty && rows.every(isValid) && !isCommitting.value;

  int totalFor(String type) => rows
      .where((row) => row.type == type)
      .fold<int>(0, (sum, row) => sum + row.amount);

  List<ParsedTransactionEntity> toEntities() => [
    for (final row in rows)
      ParsedTransactionEntity(
        type: config.showType ? row.type : null,
        amount: row.amount,
        categoryId: row.categoryId.isEmpty ? null : row.categoryId,
        walletId: row.walletId.isEmpty ? null : row.walletId,
        date: row.date,
        note: row.note.trim().isEmpty ? null : row.note.trim(),
      ),
  ];
}
