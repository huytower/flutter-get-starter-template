import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:equatable/equatable.dart';

import 'liability_direction.dart';
import 'liability_installment_entity.dart';
import 'liability_repayment_method.dart';

export 'liability_direction.dart';
export 'liability_installment_entity.dart';
export 'liability_repayment_method.dart';

/// A loan or lend record ("Khoản vay/cho vay"). Tracks the principal and
/// repayment plan; the outstanding balance and settled/outstanding status are
/// always derived from linked transactions (see [LiabilityBalanceEntity]), never
/// stored here.
class LiabilityEntity extends Equatable {
  final String id;

  /// [LiabilityDirection.borrow] or [LiabilityDirection.lend].
  final String direction;

  final int principalAmount;

  /// FK to a [CategoryEntity] of type `debt_loan` (classifies the loan type,
  /// e.g. Vay ngân hàng/TCTD, Vay thế chấp, Cho vay cá nhân).
  final String categoryId;

  /// Denormalized category label (mirrors [TransactionEntity.category]).
  final String categoryLabel;

  /// Localization key for the category name.
  final String? categoryNameKey;

  final int? categoryIconCode;
  final String? categoryIconFamily;

  /// The wallet that received (borrow) or paid out (lend) the principal.
  final String walletId;

  /// [LiabilityRepaymentMethod.installment] or [LiabilityRepaymentMethod.lumpSum].
  final String repaymentMethod;

  /// Set iff [repaymentMethod] is [LiabilityRepaymentMethod.installment].
  final List<LiabilityInstallmentEntity>? installments;

  /// Set iff [repaymentMethod] is [LiabilityRepaymentMethod.lumpSum].
  final DateTime? finalDueDate;

  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether local reminders should be scheduled ahead of the due date(s)
  /// (see `ScheduleLiabilityRemindersUseCase`) — installment: 1 day before each;
  /// lump-sum: 1 month/1 week/1 day before the final due date.
  final bool reminderBeforeDueDate;

  final String currencyCode;

  const LiabilityEntity({
    required this.id,
    required this.direction,
    required this.principalAmount,
    required this.categoryId,
    required this.categoryLabel,
    this.categoryNameKey,
    this.categoryIconCode,
    this.categoryIconFamily,
    required this.walletId,
    required this.repaymentMethod,
    this.installments,
    this.finalDueDate,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.reminderBeforeDueDate = false,
    this.currencyCode = CurrencyConstants.defaultCurrencyCode,
  });

  bool get hasBorrow => direction == LiabilityDirection.borrow;

  bool get hasLend => direction == LiabilityDirection.lend;

  bool get hasInstallment =>
      repaymentMethod == LiabilityRepaymentMethod.installment;

  LiabilityEntity copyWith({
    String? id,
    String? direction,
    int? principalAmount,
    String? categoryId,
    String? categoryLabel,
    String? categoryNameKey,
    int? categoryIconCode,
    String? categoryIconFamily,
    String? walletId,
    String? repaymentMethod,
    List<LiabilityInstallmentEntity>? installments,
    DateTime? finalDueDate,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? reminderBeforeDueDate,
    String? currencyCode,
  }) {
    return LiabilityEntity(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      principalAmount: principalAmount ?? this.principalAmount,
      categoryId: categoryId ?? this.categoryId,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      categoryNameKey: categoryNameKey ?? this.categoryNameKey,
      categoryIconCode: categoryIconCode ?? this.categoryIconCode,
      categoryIconFamily: categoryIconFamily ?? this.categoryIconFamily,
      walletId: walletId ?? this.walletId,
      repaymentMethod: repaymentMethod ?? this.repaymentMethod,
      installments: installments ?? this.installments,
      finalDueDate: finalDueDate ?? this.finalDueDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderBeforeDueDate:
          reminderBeforeDueDate ?? this.reminderBeforeDueDate,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  List<Object?> get props => [
    id,
    direction,
    principalAmount,
    categoryId,
    categoryLabel,
    categoryNameKey,
    categoryIconCode,
    categoryIconFamily,
    walletId,
    repaymentMethod,
    installments,
    finalDueDate,
    note,
    createdAt,
    updatedAt,
    reminderBeforeDueDate,
    currencyCode,
  ];
}
