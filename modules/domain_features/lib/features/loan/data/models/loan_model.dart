import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/loan_entity.dart';
import 'loan_installment_model.dart';

part 'loan_model.g.dart';

@HiveType(typeId: CcHiveBox.LOAN_TYPE_ID)
class LoanModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String direction;

  @HiveField(2)
  final String counterpartyName;

  @HiveField(3)
  final int principalAmount;

  @HiveField(4)
  final String categoryId;

  @HiveField(5)
  final String categoryLabel;

  @HiveField(6)
  final int? categoryIconCode;

  @HiveField(7)
  final String? categoryIconFamily;

  @HiveField(8)
  final String walletId;

  @HiveField(9)
  final String repaymentMethod;

  @HiveField(10)
  final List<LoanInstallmentModel>? installments;

  /// ISO-8601; set iff [repaymentMethod] is [LoanRepaymentMethod.lumpSum].
  @HiveField(11)
  final String? finalDueDate;

  @HiveField(12)
  final String? note;

  /// ISO-8601.
  @HiveField(13)
  final String createdAt;

  @HiveField(14)
  final String? remoteId;

  @HiveField(15)
  final String? syncStatus;

  @HiveField(16)
  final DateTime? lastSyncedAt;

  @HiveField(17)
  final DateTime? lastModifiedAt;

  @HiveField(18, defaultValue: false)
  final bool reminderBeforeDueDate;

  LoanModel({
    required this.id,
    required this.direction,
    required this.counterpartyName,
    required this.principalAmount,
    required this.categoryId,
    required this.categoryLabel,
    this.categoryIconCode,
    this.categoryIconFamily,
    required this.walletId,
    required this.repaymentMethod,
    this.installments,
    this.finalDueDate,
    this.note,
    required this.createdAt,
    this.remoteId,
    this.syncStatus,
    this.lastSyncedAt,
    this.lastModifiedAt,
    this.reminderBeforeDueDate = false,
  });

  factory LoanModel.fromEntity(LoanEntity entity) => LoanModel(
    id: entity.id,
    direction: entity.direction,
    counterpartyName: entity.counterpartyName,
    principalAmount: entity.principalAmount,
    categoryId: entity.categoryId,
    categoryLabel: entity.categoryLabel,
    categoryIconCode: entity.categoryIconCode,
    categoryIconFamily: entity.categoryIconFamily,
    walletId: entity.walletId,
    repaymentMethod: entity.repaymentMethod,
    installments: entity.installments
        ?.map(LoanInstallmentModel.fromEntity)
        .toList(),
    finalDueDate: entity.finalDueDate?.toIso8601String(),
    note: entity.note,
    createdAt: entity.createdAt.toIso8601String(),
    reminderBeforeDueDate: entity.reminderBeforeDueDate,
  );

  LoanEntity toEntity() => LoanEntity(
    id: id,
    direction: direction,
    counterpartyName: counterpartyName,
    principalAmount: principalAmount,
    categoryId: categoryId,
    categoryLabel: categoryLabel,
    categoryIconCode: categoryIconCode,
    categoryIconFamily: categoryIconFamily,
    walletId: walletId,
    repaymentMethod: repaymentMethod,
    installments: installments?.map((i) => i.toEntity()).toList(),
    finalDueDate: finalDueDate != null ? DateTime.parse(finalDueDate!) : null,
    note: note,
    createdAt: DateTime.parse(createdAt),
    reminderBeforeDueDate: reminderBeforeDueDate,
  );

  SyncMetadata get syncMetadata => SyncMetadata(
    localId: id,
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

  LoanModel copyWithSyncMetadata(SyncMetadata metadata) {
    return LoanModel(
      id: id,
      direction: direction,
      counterpartyName: counterpartyName,
      principalAmount: principalAmount,
      categoryId: categoryId,
      categoryLabel: categoryLabel,
      categoryIconCode: categoryIconCode,
      categoryIconFamily: categoryIconFamily,
      walletId: walletId,
      repaymentMethod: repaymentMethod,
      installments: installments,
      finalDueDate: finalDueDate,
      note: note,
      createdAt: createdAt,
      remoteId: metadata.remoteId,
      syncStatus: metadata.status.name,
      lastSyncedAt: metadata.lastSyncedAt,
      lastModifiedAt: metadata.lastModifiedAt,
      reminderBeforeDueDate: reminderBeforeDueDate,
    );
  }

  Map<String, dynamic> toFirestoreData() {
    return {
      'direction': direction,
      'counterpartyName': counterpartyName,
      'principalAmount': principalAmount,
      'categoryId': categoryId,
      'categoryLabel': categoryLabel,
      'categoryIconCode': categoryIconCode,
      'categoryIconFamily': categoryIconFamily,
      'walletId': walletId,
      'repaymentMethod': repaymentMethod,
      'installments': installments?.map((i) => i.toJson()).toList(),
      'finalDueDate': finalDueDate,
      'note': note,
      'createdAt': createdAt,
      'reminderBeforeDueDate': reminderBeforeDueDate,
    };
  }

  factory LoanModel.fromFirestoreData(
    Map<String, dynamic> data,
    String localId,
  ) {
    final remoteModifiedAt = data['lastModifiedAt'] as String?;
    final parsedModifiedAt = remoteModifiedAt != null
        ? DateTime.tryParse(remoteModifiedAt)
        : null;

    return LoanModel(
      id: localId,
      direction: data['direction'] as String,
      counterpartyName: data['counterpartyName'] as String,
      principalAmount: data['principalAmount'] as int,
      categoryId: data['categoryId'] as String,
      categoryLabel: data['categoryLabel'] as String,
      categoryIconCode: data['categoryIconCode'] as int?,
      categoryIconFamily: data['categoryIconFamily'] as String?,
      walletId: data['walletId'] as String,
      repaymentMethod: data['repaymentMethod'] as String,
      installments: (data['installments'] as List?)
          ?.map((i) => LoanInstallmentModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      finalDueDate: data['finalDueDate'] as String?,
      note: data['note'] as String?,
      createdAt: data['createdAt'] as String,
      remoteId: data['remoteId'] as String?,
      syncStatus: SyncStatus.synced.name,
      lastSyncedAt: parsedModifiedAt,
      lastModifiedAt: parsedModifiedAt,
      reminderBeforeDueDate: data['reminderBeforeDueDate'] as bool? ?? false,
    );
  }
}
