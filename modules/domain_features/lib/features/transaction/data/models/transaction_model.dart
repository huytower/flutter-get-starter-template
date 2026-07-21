import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: CcHiveBox.TRANSACTION_TYPE_ID)
@JsonSerializable()
class TransactionModel {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? type;

  @HiveField(2)
  final int? amount;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final String? date;

  @HiveField(6)
  final String? walletId;

  @HiveField(7)
  final String? categoryId;

  @HiveField(8)
  final String? budgetId;

  /// ISO-8601 timestamp; non-null marks the record as soft-deleted.
  @HiveField(9)
  final String? deletedAt;

  /// Links the two legs of a transfer; null for income/expense records.
  @HiveField(10)
  final String? transferId;

  @HiveField(11)
  final int? categoryIconCode;

  @HiveField(12)
  final String? categoryIconFamily;

  @HiveField(13)
  final String? remoteId;

  @HiveField(14)
  final String? syncStatus;

  @HiveField(15)
  final DateTime? lastSyncedAt;

  @HiveField(16)
  final DateTime? lastModifiedAt;

  TransactionModel({
    this.id,
    this.type,
    this.amount,
    this.category,
    this.note,
    this.date,
    this.walletId,
    this.categoryId,
    this.budgetId,
    this.deletedAt,
    this.transferId,
    this.categoryIconCode,
    this.categoryIconFamily,
    this.remoteId,
    this.syncStatus,
    this.lastSyncedAt,
    this.lastModifiedAt,
  });

  TransactionModel copyWith({String? deletedAt}) => TransactionModel(
    id: id,
    type: type,
    amount: amount,
    category: category,
    note: note,
    date: date,
    walletId: walletId,
    categoryId: categoryId,
    budgetId: budgetId,
    deletedAt: deletedAt ?? this.deletedAt,
    transferId: transferId,
    categoryIconCode: categoryIconCode,
    categoryIconFamily: categoryIconFamily,
  );

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  factory TransactionModel.fromEntity(TransactionEntity entity) =>
      TransactionModel(
        id: entity.id,
        type: entity.type,
        amount: entity.amount,
        category: entity.category,
        note: entity.note,
        date: entity.date.toIso8601String(),
        walletId: entity.walletId,
        categoryId: entity.categoryId,
        budgetId: entity.budgetId,
        deletedAt: entity.deletedAt?.toIso8601String(),
        transferId: entity.transferId,
        categoryIconCode: entity.categoryIconCode,
        categoryIconFamily: entity.categoryIconFamily,
      );

  TransactionEntity toEntity() => TransactionEntity(
    id: id ?? '',
    type: type ?? '',
    amount: amount ?? 0,
    category: category ?? '',
    categoryId: categoryId ?? '',
    budgetId: budgetId,
    note: note,
    date: date != null ? DateTime.parse(date!) : DateTime.now(),
    walletId: walletId ?? '',
    transferId: transferId,
    deletedAt: deletedAt != null ? DateTime.parse(deletedAt!) : null,
    categoryIconCode: categoryIconCode,
    categoryIconFamily: categoryIconFamily,
  );

  SyncMetadata get syncMetadata => SyncMetadata(
    localId: id ?? '',
    remoteId: remoteId,
    status: syncStatus != null
        ? SyncStatus.values.firstWhere(
            (e) => e.name == syncStatus,
            orElse: () => SyncStatus.pending,
          )
        : SyncStatus.pending,
    lastSyncedAt: lastSyncedAt,
    lastModifiedAt: lastModifiedAt,
  );

  TransactionModel copyWithSyncMetadata(SyncMetadata metadata) {
    return TransactionModel(
      id: id,
      type: type,
      amount: amount,
      category: category,
      note: note,
      date: date,
      walletId: walletId,
      categoryId: categoryId,
      budgetId: budgetId,
      deletedAt: deletedAt,
      transferId: transferId,
      categoryIconCode: categoryIconCode,
      categoryIconFamily: categoryIconFamily,
      remoteId: metadata.remoteId,
      syncStatus: metadata.status.name,
      lastSyncedAt: metadata.lastSyncedAt,
      lastModifiedAt: metadata.lastModifiedAt,
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date,
      'walletId': walletId,
      'categoryId': categoryId,
      'budgetId': budgetId,
      'deletedAt': deletedAt,
      'transferId': transferId,
      'categoryIconCode': categoryIconCode,
      'categoryIconFamily': categoryIconFamily,
    };
  }

  factory TransactionModel.fromFirestoreData(
    Map<String, dynamic> data,
    String localId,
  ) {
    final remoteModifiedAt = data['lastModifiedAt'] as String?;
    final parsedModifiedAt = remoteModifiedAt != null
        ? DateTime.tryParse(remoteModifiedAt)
        : null;

    return TransactionModel(
      id: localId,
      type: data['type'] as String?,
      amount: data['amount'] as int?,
      category: data['category'] as String?,
      note: data['note'] as String?,
      date: data['date'] as String?,
      walletId: data['walletId'] as String?,
      categoryId: data['categoryId'] as String?,
      budgetId: data['budgetId'] as String?,
      deletedAt: data['deletedAt'] as String?,
      transferId: data['transferId'] as String?,
      categoryIconCode: data['categoryIconCode'] as int?,
      categoryIconFamily: data['categoryIconFamily'] as String?,
      remoteId: data['remoteId'] as String?,
      syncStatus: SyncStatus.synced.name,
      lastSyncedAt: parsedModifiedAt,
      lastModifiedAt: parsedModifiedAt,
    );
  }
}
