import 'package:flutter/widgets.dart';

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
