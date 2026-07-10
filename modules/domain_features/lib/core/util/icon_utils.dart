import 'package:flutter/material.dart';

/// Builds an [IconData] from a stored [codePoint].
///
/// Icon codepoints are persisted as ints, so the resulting [IconData] can't be
/// `const`. Centralizing construction keeps the
/// `non_const_argument_for_const_parameter` lint — a false positive for
/// data-driven icons — in a single place, and honours a stored [fontFamily]
/// when present. Release builds must pass `--no-tree-shake-icons`.
IconData iconDataFromCode(int codePoint, {String? fontFamily}) {
  // ignore: non_const_argument_for_const_parameter
  return IconData(codePoint, fontFamily: fontFamily ?? 'MaterialIcons');
}

/// Default icon per wallet type ('cash' / 'bank' / 'credit').
///
/// Referencing the `Icons` constants keeps these glyphs tree-shake-safe.
IconData walletIconFor(String type) {
  switch (type) {
    case 'cash':
      return Icons.payments;
    case 'credit':
      return Icons.credit_card;
    default:
      return Icons.account_balance;
  }
}
