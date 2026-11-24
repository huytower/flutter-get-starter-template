import 'package:flutter/material.dart';

import 'prj_localization.dart';

/// Extension to easily access localization methods on [BuildContext].
extension LocalizationExtension on BuildContext {
  /// Shortcut for [PrjLocalization.translate].
  String tr(String key, {List<String>? args, Map<String, String>? namedArgs}) {
    return PrjLocalization.translate(key, args: args, namedArgs: namedArgs);
  }

  /// Shortcut for [PrjLocalization.plural].
  String trPlural(String key, num count, {List<String>? args}) {
    return PrjLocalization.plural(key, count, args: args);
  }
}
