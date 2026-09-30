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

  /// FK to the Liability this leg belongs to; null for non-liability records.
  @HiveField(17)
  final String? liabilityId;

  /// FK to the investment position this leg belongs to; null for non-investment
  /// records. See [TransactionEntity.investmentWalletId].
  @HiveField(18)
  final String? investmentWalletId;

  /// Phase 3.5 location-based suggestion. See [TransactionEntity.lat]/[lng].
  @HiveField(19)
  final double? lat;

  @HiveField(20)
  final double? lng;

  @HiveField(21)
  final String? currencyCode;

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
    this.liabilityId,
    this.investmentWalletId,
    this.lat,
    this.lng,
    this.currencyCode,
  });

  TransactionModel copyWith({
    String? id,
    String? type,
    int? amount,
    String? category,
    String? note,
    String? date,
    String? walletId,
    String? categoryId,
    String? budgetId,
    String? deletedAt,
    String? transferId,
    int? categoryIconCode,
    String? categoryIconFamily,
    String? remoteId,
    String? syncStatus,
    DateTime? lastSyncedAt,
    DateTime? lastModifiedAt,
    String? liabilityId,
    String? investmentWalletId,
    double? lat,
    double? lng,
    String? currencyCode,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      budgetId: budgetId ?? this.budgetId,
      deletedAt: deletedAt ?? this.deletedAt,
      transferId: transferId ?? this.transferId,
      categoryIconCode: categoryIconCode ?? this.categoryIconCode,
      categoryIconFamily: categoryIconFamily ?? this.categoryIconFamily,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      liabilityId: liabilityId ?? this.liabilityId,
      investmentWalletId: investmentWalletId ?? this.investmentWalletId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) =>
      TransactionModel(
        id: entity.id,
        type: entity.type,
        amount: entity.amount,
        category: entity.category,
        categoryId: entity.categoryId,
        budgetId: entity.budgetId,
        note: entity.note,
        date: entity.date.toIso8601String(),
        walletId: entity.walletId,
        categoryIconCode: entity.categoryIconCode,
        categoryIconFamily: entity.categoryIconFamily,
        transferId: entity.transferId,
        liabilityId: entity.liabilityId,
        investmentWalletId: entity.investmentWalletId,
        deletedAt: entity.deletedAt?.toIso8601String(),
        lat: entity.lat,
        lng: entity.lng,
      );

  TransactionEntity toEntity() => TransactionEntity(
    id: id ?? '',
    type: type ?? TransactionType.expense,
    amount: amount ?? 0,
    category: category ?? '',
    categoryId: categoryId ?? '',
    budgetId: budgetId,
    note: note,
    date: date != null
        ? DateTime.tryParse(date!) ?? DateTime.now()
        : DateTime.now(),
    walletId: walletId ?? '',
    categoryIconCode: categoryIconCode,
    categoryIconFamily: categoryIconFamily,
    transferId: transferId,
    liabilityId: liabilityId,
    investmentWalletId: investmentWalletId,
    deletedAt: deletedAt != null ? DateTime.tryParse(deletedAt!) : null,
    lat: lat,
    lng: lng,
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
      budgetId: budgetId,
      note: note,
      date: date,
      walletId: walletId,
      categoryId: categoryId,
      categoryIconCode: categoryIconCode,
      categoryIconFamily: categoryIconFamily,
      transferId: transferId,
      liabilityId: liabilityId,
      investmentWalletId: investmentWalletId,
      deletedAt: deletedAt,
      lat: lat,
      lng: lng,
      currencyCode: currencyCode,
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
      'categoryId': categoryId,
      'budgetId': budgetId,
      'note': note,
      'date': date,
      'walletId': walletId,
      'categoryIconCode': categoryIconCode,
      'categoryIconFamily': categoryIconFamily,
      'transferId': transferId,
      'liabilityId': liabilityId,
      'investmentWalletId': investmentWalletId,
      'deletedAt': deletedAt,
      'lat': lat,
      'lng': lng,
      'currencyCode': currencyCode ?? 'VND',
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
      amount: (data['amount'] as num?)?.toInt(),
      category: data['category'] as String?,
      categoryId: data['categoryId'] as String?,
      budgetId: data['budgetId'] as String?,
      note: data['note'] as String?,
      date: data['date'] as String?,
      walletId: data['walletId'] as String?,
      categoryIconCode: (data['categoryIconCode'] as num?)?.toInt(),
      categoryIconFamily: data['categoryIconFamily'] as String?,
      transferId: data['transferId'] as String?,
      liabilityId: data['liabilityId'] as String?,
      investmentWalletId: data['investmentWalletId'] as String?,
      deletedAt: data['deletedAt'] as String?,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      currencyCode: data['currencyCode'] as String? ?? 'VND',
      remoteId: data['remoteId'] as String?,
      syncStatus: SyncStatus.synced.name,
      lastSyncedAt: parsedModifiedAt,
      lastModifiedAt: parsedModifiedAt,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
