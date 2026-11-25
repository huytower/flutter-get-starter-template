import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:equatable/equatable.dart';

import 'transaction_type.dart';

export 'transaction_type.dart';

/// Only [TransactionType.income], [TransactionType.expense], debt/loan, and
/// investment entries dated within this many days of "now" can be corrected
/// — the single source of truth shared by `UpdateTransactionUseCase`'s
/// validation and the report list's edit-affordance visibility, so the two
/// can't drift apart.
const int transactionEditWindowDays = 30;

class TransactionEntity extends Equatable {
  final String id;
  final String type;
  final int amount;

  /// Human-readable category label (denormalized for display).
  final String category;

  /// FK to the owning [CategoryEntity] (used for budget aggregation).
  final String categoryId;

  /// FK to the [BudgetLimitEntity] this expense counts against (nullable).
  final String? budgetId;

  final String? note;
  final DateTime date;
  final String walletId;

  /// Denormalized icon code for UI display.
  final int? categoryIconCode;
  final String? categoryIconFamily;

  /// Links the two legs of a transfer. Null for income/expense records.
  final String? transferId;

  /// FK to the [LiabilityEntity] this leg belongs to. Set for
  /// debtBorrow/debtLend/debtRepay/debtCollect records, null otherwise.
  final String? liabilityId;

  /// FK to the investment position (`WalletType.investment`) this leg
  /// belongs to. Set on every investmentOut/investmentIn/investmentReturn
  /// record, mirroring how [liabilityId] tags Loan legs — needed because
  /// [walletId] on these legs points at whichever *real* wallet the money
  /// moved through (liquid wallet for investmentOut/investmentReturn, the
  /// position itself for investmentIn), not necessarily the position.
  final String? investmentWalletId;

  /// When non-null the record is soft-deleted and excluded from all reads.
  final DateTime? deletedAt;

  /// Foreground-only GPS fix captured when the entry form was opened (Phase
  /// 3.5 location-based suggestion). Null when location was unavailable/
  /// denied/not an expense — never backfilled for older records.
  final double? lat;
  final double? lng;
  final String currencyCode;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.categoryId = '',
    this.budgetId,
    this.note,
    required this.date,
    required this.walletId,
    this.categoryIconCode,
    this.categoryIconFamily,
    this.transferId,
    this.liabilityId,
    this.investmentWalletId,
    this.deletedAt,
    this.lat,
    this.lng,
    this.currencyCode = CurrencyConstants.defaultCurrencyCode,
  });

  /// True for either leg of a transfer.
  bool get hasTransfer =>
      type == TransactionType.transferOut || type == TransactionType.transferIn;

  /// True for any Investment tab leg — Chi ra's two transfer-like legs
  /// ([TransactionType.investmentOut]/[investmentIn]) or a Thu vào
  /// ([TransactionType.investmentReturn]). None of these are real
  /// income/expense, so — like [hasTransfer] — they're excluded from
  /// income/expense reports and history.
  bool get hasInvestmentActivity =>
      type == TransactionType.investmentOut ||
      type == TransactionType.investmentIn ||
      type == TransactionType.investmentReturn;

  /// True for any Loan tab leg — initiation ([TransactionType.debtBorrow]/
  /// [TransactionType.debtLend]) or settlement
  /// ([TransactionType.debtRepay]/[TransactionType.debtCollect]). None of
  /// these are real income/expense, so — like [hasTransfer]/
  /// [hasInvestmentActivity] — they're excluded from income/expense reports
  /// and history.
  bool get hasDebtActivity =>
      type == TransactionType.debtBorrow ||
      type == TransactionType.debtLend ||
      type == TransactionType.debtRepay ||
      type == TransactionType.debtCollect;

  bool get hasDeleted => deletedAt != null;

  /// Returns a numeric value for sorting. Suffixes like `_init`, `_in`,
  /// `_out` are stripped to recover the original microsecond timestamp,
  /// ensuring creation-order stability even for multi-leg transactions.
  double get sortKey {
    final cleaned = id.split('_').first;
    return double.tryParse(cleaned) ?? 0;
  }

  TransactionEntity copyWith({
    String? id,
    String? type,
    int? amount,
    String? category,
    String? categoryId,
    String? budgetId,
    String? note,
    DateTime? date,
    String? walletId,
    int? categoryIconCode,
    String? categoryIconFamily,
    String? transferId,
    String? liabilityId,
    String? investmentWalletId,
    DateTime? deletedAt,
    double? lat,
    double? lng,
    String? currencyCode,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      budgetId: budgetId ?? this.budgetId,
      note: note ?? this.note,
      date: date ?? this.date,
      walletId: walletId ?? this.walletId,
      categoryIconCode: categoryIconCode ?? this.categoryIconCode,
      categoryIconFamily: categoryIconFamily ?? this.categoryIconFamily,
      transferId: transferId ?? this.transferId,
      liabilityId: liabilityId ?? this.liabilityId,
      investmentWalletId: investmentWalletId ?? this.investmentWalletId,
      deletedAt: deletedAt ?? this.deletedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    category,
    categoryId,
    budgetId,
    note,
    date,
    walletId,
    categoryIconCode,
    categoryIconFamily,
    transferId,
    liabilityId,
    investmentWalletId,
    deletedAt,
    lat,
    lng,
    currencyCode,
  ];
}
