import 'package:flutter/material.dart';

import '../../data/data_source/color/prj_colors.dart';

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

  /// Investment — metallic gold, solid accent for text, icons and tints.
  Color get investmentAccent =>
      _isDarkForm ? PrjColors.darkInvestmentAccent : PrjColors.investmentAccent;

  /// Foreground (label / icon) drawn on top of [investmentGoldGradient].
  Color get onInvestmentGold => PrjColors.onInvestmentGold;

  /// Opaque metallic-gold fill for primary surfaces (e.g. the submit button):
  /// a diagonal highlight → gold → highlight band → deep gold sweep.
  LinearGradient get investmentGoldGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      PrjColors.investmentGoldHighlight,
      PrjColors.investmentGoldMid,
      PrjColors.investmentGoldHighlight,
      PrjColors.investmentGoldDeep,
    ],
    stops: [0.0, 0.42, 0.62, 1.0],
  );

  /// Translucent version of [investmentGoldGradient] for card backgrounds that
  /// carry their own text (e.g. wallet cards), so content stays readable.
  LinearGradient get investmentGoldCardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      PrjColors.investmentGoldHighlight.withValues(alpha: 0.28),
      PrjColors.investmentGoldMid.withValues(alpha: 0.30),
      PrjColors.investmentGoldHighlight.withValues(alpha: 0.18),
      PrjColors.investmentGoldDeep.withValues(alpha: 0.28),
    ],
    stops: const [0.0, 0.42, 0.62, 1.0],
  );

  /// Liability zone (borrow + lend) — the violet of the liability hero card,
  /// for text, icons and tints.
  Color get liabilityAccent =>
      _isDarkForm ? PrjColors.liabilityHighlight : PrjColors.liability;

  /// Opaque violet fill for liability icon badges; pair with `onPrimary`.
  LinearGradient get liabilityGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      PrjColors.liabilityHighlight,
      PrjColors.liability,
      PrjColors.liabilityDeep,
    ],
  );

  /// Translucent version of [liabilityGradient] for card backgrounds that
  /// carry their own text.
  LinearGradient get liabilityCardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      PrjColors.liabilityHighlight.withValues(alpha: 0.14),
      PrjColors.liability.withValues(alpha: 0.10),
      PrjColors.liabilityHighlight.withValues(alpha: 0.06),
      PrjColors.liabilityDeep.withValues(alpha: 0.16),
    ],
    stops: const [0.0, 0.42, 0.62, 1.0],
  );

  /// Borrow (liability) — deep purple.
  Color get borrowAccent =>
      _isDarkForm ? PrjColors.darkBorrowAccent : PrjColors.borrowAccent;

  /// Lend — orchid / lavender.
  Color get lendAccent =>
      _isDarkForm ? PrjColors.darkLendAccent : PrjColors.lendAccent;
}

/// Shade used for the second leg of a form (repay, collect, return).
///
/// Driven by [PrjColors.formSecondaryAlpha]; at 1.0 it is the accent itself.
extension PrjSecondaryShade on Color {
  Color get secondaryShade => withValues(alpha: PrjColors.formSecondaryAlpha);
}
