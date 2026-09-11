import 'package:easy_localization/easy_localization.dart' as el;
import 'package:message/cc_locale_keys.dart';

/// Helper to handle budget name localization and formatting.
class BudgetNameHelper {
  BudgetNameHelper._();

  /// Known legacy / alternative default names mapped to category keys.
  static const Map<String, List<String>> _knownAliases = {
    'category.food_drink': [
      'food & drink',
      'dining & coffee',
      'dining and coffee',
      'food and drink',
      'ăn uống & cà phê',
      'an uong & ca phe',
      'ăn uống',
      'an uong',
      'cà phê',
      'ca phe',
    ],
    'category.electricity': [
      'electricity',
      'điện',
      'dien',
      'tiền điện',
      'tien dien',
    ],
    'category.phone': [
      'phone',
      'điện thoại',
      'dien thoai',
      'tiền điện thoại',
      'smartphone',
    ],
    'category.internet': ['internet', 'wifi', 'mạng', 'mang'],
    'category.gas': ['gas', 'xăng', 'xang', 'xăng xe', 'xang xe'],
    'category.water': ['water', 'nước', 'nuoc', 'tiền nước', 'tien nuoc'],
    'category.rent': ['rent', 'thuê nhà', 'thue nha', 'tiền nhà', 'tien nha'],
    'category.taxi': ['taxi', 'xe ôm', 'xe cong nghe'],
    'category.parking': ['parking', 'đỗ xe', 'do xe', 'gửi xe', 'gui xe'],
    'category.maintenance': ['maintenance', 'bảo trì', 'bao tri', 'sửa xe', 'sua xe'],
    'category.market_supermarket': [
      'market & supermarket',
      'đi chợ & siêu thị',
      'di cho & sieu thi',
      'siêu thị',
      'sieu thi',
      'đi chợ',
      'di cho',
      'market',
      'supermarket',
    ],
    'category.tuition': ['tuition', 'học phí', 'hoc phi'],
    'category.gym': ['gym', 'thể dục gym', 'the duc gym', 'tập gym'],
    'category.medicine': ['medicine', 'thuốc', 'thuoc'],
    'category.doctor': ['doctor', 'khám bệnh', 'kham benh'],
  };

  /// Returns the localized display name for a budget or category.
  /// If [name] is recognized as a default category name and [categoryNameKey]
  /// is provided, it returns the translated string via [el.tr].
  /// Otherwise, it returns [name].
  static String getDisplayName({
    required String name,
    required String? categoryNameKey,
  }) {
    if (categoryNameKey != null &&
        isDefaultName(name, key: categoryNameKey)) {
      return el.tr(categoryNameKey);
    }
    if (categoryNameKey == null) {
      final searchName = name.trim().toLowerCase();
      for (final entry in _knownAliases.entries) {
        if (entry.value.contains(searchName) ||
            entry.key.toLowerCase() == searchName ||
            entry.key.split('.').last.toLowerCase() == searchName) {
          return el.tr(entry.key);
        }
      }
    }
    return name;
  }

  /// Returns true if the [name] matches a known default name (Vietnamese or English)
  /// for a category.
  static bool isDefaultName(String name, {required String key}) {
    final searchName = name.trim().toLowerCase();

    // 1. Direct match on key or stripped key (e.g. 'category.food_drink' or 'food_drink')
    if (searchName == key.trim().toLowerCase() ||
        searchName == key.split('.').last.toLowerCase()) {
      return true;
    }

    // 2. Check against all translations across all locales in CodegenLoader
    for (final localeData in CodegenLoader.mapLocales.values) {
      final value = _getNestedValue(localeData, key);
      if (value != null &&
          value.toString().trim().toLowerCase() == searchName) {
        return true;
      }
    }

    // 3. Check current runtime translation
    if (el.tr(key).trim().toLowerCase() == searchName) {
      return true;
    }

    // 4. Check known aliases
    final aliases = _knownAliases[key];
    if (aliases != null && aliases.contains(searchName)) {
      return true;
    }

    return false;
  }

  /// Resolves a nested key (e.g., 'category.food_drink') from a translation map.
  static dynamic _getNestedValue(Map<String, dynamic> map, String key) {
    final parts = key.split('.');
    dynamic current = map;
    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }
}
