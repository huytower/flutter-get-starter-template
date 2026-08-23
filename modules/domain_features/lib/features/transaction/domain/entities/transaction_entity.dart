import 'package:equatable/equatable.dart';

/// Only [TransactionType.income], [TransactionType.expense], debt/loan, and
/// investment entries dated within this many days of "now" can be corrected
/// — the single source of truth shared by `UpdateTransactionUseCase`'s
/// validation and the report list's edit-affordance visibility, so the two
/// can't drift apart.
const int transactionEditWindowDays = 30;

/// Discriminators stored in [TransactionEntity.type].
///
/// A transfer ("Chuyển khoản") is stored as two linked legs: a [transferOut]
/// on the source wallet and a [transferIn] on the destination, sharing a
/// [TransactionEntity.transferId]. Transfers are excluded from income/expense
/// reports and history — they only move money between wallets.
abstract class TransactionType {
  static const String income = 'income';
  static const String expense = 'expense';

  @Deprecated(
    'Superseded by debtBorrow/debtLend/debtRepay/debtCollect. No longer '
    'written by any form; kept only so any existing dev-stage records still '
    'parse.',
  )
  static const String debtLoan = 'debt_loan';

  static const String transferOut = 'transfer_out';
  static const String transferIn = 'transfer_in';

  /// Chi ra (capital contribution): two legs sharing a
  /// [TransactionEntity.transferId] like [transferOut]/[transferIn] —
  /// [investmentOut] on the liquid wallet the money leaves, [investmentIn] on
  /// the investment wallet it arrives at.
  static const String investmentOut = 'investment_out';
  static const String investmentIn = 'investment_in';

  /// Thu vào (profit/return): a single leg credited straight to the
  /// investment wallet — no liquid wallet is touched. Distinct from
  /// [investmentIn] so a future ROI calculation can separate contributed
  /// capital from returns on the same wallet.
  static const String investmentReturn = 'investment_return';

  /// Đi vay (borrow): a single leg crediting the wallet that received the
  /// principal, tagged with [TransactionEntity.loanId].
  static const String debtBorrow = 'debt_borrow';

  /// Cho vay (lend): a single leg debiting the wallet the principal left
  /// from, tagged with [TransactionEntity.loanId].
  static const String debtLend = 'debt_lend';

  /// Trả nợ: settles a [debtBorrow] loan — debits the paying wallet.
  static const String debtRepay = 'debt_repay';

  /// Thu nợ: settles a [debtLend] loan — credits the collecting wallet.
  static const String debtCollect = 'debt_collect';
}

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

  /// FK to the [LoanEntity] this leg belongs to. Set for
  /// debtBorrow/debtLend/debtRepay/debtCollect records, null otherwise.
  final String? loanId;

  /// FK to the investment position (`WalletType.investment`) this leg
  /// belongs to. Set on every investmentOut/investmentIn/investmentReturn
  /// record, mirroring how [loanId] tags Loan legs — needed because
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
    this.loanId,
    this.investmentWalletId,
    this.deletedAt,
    this.lat,
    this.lng,
  });

  /// True for either leg of a transfer.
  bool get isTransfer =>
      type == TransactionType.transferOut || type == TransactionType.transferIn;

  /// True for any Investment tab leg — Chi ra's two transfer-like legs
  /// ([TransactionType.investmentOut]/[investmentIn]) or a Thu vào
  /// ([TransactionType.investmentReturn]). None of these are real
  /// income/expense, so — like [isTransfer] — they're excluded from
  /// income/expense reports and history.
  bool get isInvestmentActivity =>
      type == TransactionType.investmentOut ||
      type == TransactionType.investmentIn ||
      type == TransactionType.investmentReturn;

  /// True for any Loan tab leg — initiation ([TransactionType.debtBorrow]/
  /// [TransactionType.debtLend]) or settlement
  /// ([TransactionType.debtRepay]/[TransactionType.debtCollect]). None of
  /// these are real income/expense, so — like [isTransfer]/
  /// [isInvestmentActivity] — they're excluded from income/expense reports
  /// and history.
  bool get isDebtActivity =>
      type == TransactionType.debtBorrow ||
      type == TransactionType.debtLend ||
      type == TransactionType.debtRepay ||
      type == TransactionType.debtCollect;

  bool get isDeleted => deletedAt != null;

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
    String? loanId,
    String? investmentWalletId,
    DateTime? deletedAt,
    double? lat,
    double? lng,
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
      loanId: loanId ?? this.loanId,
      investmentWalletId: investmentWalletId ?? this.investmentWalletId,
      deletedAt: deletedAt ?? this.deletedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
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
    loanId,
    investmentWalletId,
    deletedAt,
    lat,
    lng,
  ];
}
