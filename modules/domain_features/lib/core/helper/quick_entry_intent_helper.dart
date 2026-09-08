import 'merchant_match_helper.dart';
import 'quick_entry_parser_helper.dart';

/// Centralized helper for detecting intent sub-segments and directions
/// (e.g. Return vs Contribute, Repay vs Borrow) across all transaction forms.
class QuickEntryIntentHelper {
  QuickEntryIntentHelper._();

  /// Explicit intent keywords used for high-level tab switching (High priority).
  static const Map<QuickEntryIntent, List<String>> intentRoots = {
    QuickEntryIntent.income: ['income', 'luong', 'thuong'],
    QuickEntryIntent.investment: [
      'dau tu',
      'mua vang',
      'mua chung khoan',
      'gui tiet kiem',
    ],
    QuickEntryIntent.expense: ['chi tieu', 'spent'],
  };

  /// Maps directional verbs to their financial intent.
  static const Map<String, QuickEntryIntent> directionalVerbs = {
    // Inflow (+) -> Income
    'nhan': QuickEntryIntent.income,
    'duoc': QuickEntryIntent.income,
    'thu vao': QuickEntryIntent.income,
    'received': QuickEntryIntent.income,
    'got': QuickEntryIntent.income,
    'bonus': QuickEntryIntent.income,

    // Outflow (-) -> Expense
    'chi': QuickEntryIntent.expense,
    'tra tien': QuickEntryIntent.expense,
    'pay': QuickEntryIntent.expense,
    'spent': QuickEntryIntent.expense,
    'bought': QuickEntryIntent.expense,
    'mua': QuickEntryIntent.expense,
    'cho': QuickEntryIntent.expense, // Indicator for giving/lending
    // Loan-related Outflow (Giving to others) -> Lend
    'cho vay': QuickEntryIntent.lend,
    'chovay': QuickEntryIntent.lend,
    'cho ban vay': QuickEntryIntent.lend,
    'chobanvay': QuickEntryIntent.lend,
    'cho muon': QuickEntryIntent.lend,
    'cho muon tien': QuickEntryIntent.lend,
    'chomuontien': QuickEntryIntent.lend,
    'dua tien cho': QuickEntryIntent.lend,
    'ung truoc': QuickEntryIntent.lend,
    'thu no': QuickEntryIntent.lend,
    'thuno': QuickEntryIntent.lend,
    'thu tien': QuickEntryIntent.lend,
    'thutien': QuickEntryIntent.lend,
    'doi no': QuickEntryIntent.lend,
    'thu tien no': QuickEntryIntent.lend,
    'lend': QuickEntryIntent.lend,

    // Loan-related Inflow (Taking from others) -> Debt
    'di vay': QuickEntryIntent.debt,
    'muon tien': QuickEntryIntent.debt,
    'tra no': QuickEntryIntent.debt,
    'trano': QuickEntryIntent.debt,
    'thanh toan no': QuickEntryIntent.debt,
    'thanhtoanno': QuickEntryIntent.debt,
    'dong lai': QuickEntryIntent.debt,
    'repay': QuickEntryIntent.debt,
    'borrow': QuickEntryIntent.debt,
    'loan': QuickEntryIntent.debt,

    // Investment
    'dau tu': QuickEntryIntent.investment,
    'contribution': QuickEntryIntent.investment,
    'invest': QuickEntryIntent.investment,
  };

  /// Categories that are ambiguous and need a directional verb to decide.
  /// If no directional verb is found, the 'default' intent is used.
  static const Map<String, Map<String, QuickEntryIntent>> ambiguousContexts = {
    'li xi': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'lixi': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'tet': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'tet nguyen dan': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'loc': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'la': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'ngay le': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'holiday': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'annual year': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'benefit': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'quyen loi': {
      'inflow': QuickEntryIntent.income,
      'outflow': QuickEntryIntent.expense,
      'default': QuickEntryIntent.expense,
    },
    'vay': {
      'inflow': QuickEntryIntent.debt,
      'outflow': QuickEntryIntent.lend,
      'default': QuickEntryIntent.debt,
    },
    'muon': {
      'inflow': QuickEntryIntent.debt,
      'outflow': QuickEntryIntent.lend,
      'default': QuickEntryIntent.debt,
    },
  };

  /// Keywords indicating an Investment Return (Inflow/Profit).
  static const List<String> investmentReturnKeywords = [
    'ban',
    'rut',
    'thu vao',
    'nhan',
    'profit',
    'return',
  ];

  /// Keywords indicating a Debt Repayment (Outflow/Repay).
  static const List<String> debtRepayKeywords = [
    'tra no',
    'trano',
    'thanh toan no',
    'thanhtoanno',
    'dong lai',
    'repay',
    'payback',
  ];

  /// Keywords indicating a Lend Collection (Inflow/Collect).
  static const List<String> lendCollectKeywords = [
    'thu no',
    'thuno',
    'thu tien',
    'thutien',
    'doi no',
    'thu tien no',
    'thu vao',
    'nhan',
    'collect',
    'lay tien no',
    'doi tien no',
    'ban tra no',
    'nguoi ta tra',
  ];

  /// Returns true if [text] indicates an investment return action.
  static bool isInvestmentReturn(String text) {
    final normalized = stripVietnameseDiacritics(text.toLowerCase());
    return investmentReturnKeywords.any((k) => normalized.contains(k));
  }

  /// Returns true if [text] indicates a debt repayment action.
  static bool isDebtRepayment(String text) {
    final normalized = stripVietnameseDiacritics(text.toLowerCase());
    return debtRepayKeywords.any((k) => normalized.contains(k));
  }

  /// Returns true if [text] indicates a lend collection action.
  static bool isLendCollection(String text) {
    final normalized = stripVietnameseDiacritics(text.toLowerCase());
    return lendCollectKeywords.any((k) => normalized.contains(k));
  }
}
