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
  /// principal, tagged with [TransactionEntity.liabilityId].
  static const String debtBorrow = 'debt_borrow';

  /// Cho vay (lend): a single leg debiting the wallet the principal left
  /// from, tagged with [TransactionEntity.liabilityId].
  static const String debtLend = 'debt_lend';

  /// Trả nợ: settles a [debtBorrow] loan — debits the paying wallet.
  static const String debtRepay = 'debt_repay';

  /// Thu nợ: settles a [debtLend] loan — credits the collecting wallet.
  static const String debtCollect = 'debt_collect';
}

