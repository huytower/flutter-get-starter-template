import 'package:flutter/material.dart';

import '../../data/data_source/color/prj_color.dart';

/// Brand accent colors for the transaction entry forms.
///
/// Resolves the light/dark pair of each [PrjColors] form accent from the
/// ambient [Theme] brightness, so forms never hardcode a hex value or reuse the
/// status colors (success / error / warning).
extension PrjFormAccent on BuildContext {
  bool get _isDarkForm => Theme.of(this).brightness == Brightness.dark;

  /// Income — teal.
  Color get incomeAccent =>
      _isDarkForm ? PrjColors.darkIncomeAccent : PrjColors.incomeAccent;

  /// Expense — blue.
  Color get expenseAccent =>
      _isDarkForm ? PrjColors.darkExpenseAccent : PrjColors.expenseAccent;

  /// Investment — amber gold.
  Color get investmentAccent =>
      _isDarkForm ? PrjColors.darkInvestmentAccent : PrjColors.investmentAccent;

  /// Borrow (liability) — deep purple.
  Color get borrowAccent =>
      _isDarkForm ? PrjColors.darkBorrowAccent : PrjColors.borrowAccent;

  /// Lend — orchid / lavender.
  Color get lendAccent =>
      _isDarkForm ? PrjColors.darkLendAccent : PrjColors.lendAccent;
}
