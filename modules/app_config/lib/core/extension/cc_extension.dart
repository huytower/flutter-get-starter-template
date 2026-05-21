import 'package:cc_sdk/core/constants/cc_constants.dart';
import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:data/core/helper/data_helper.dart';
import 'package:intl/intl.dart';

// Re-export dartx so consumers get its extensions (isNullOrEmpty, capitalize,
// isNullOrBlank, firstOrNull, etc.) without an extra import.
export 'package:dartx/dartx.dart';

/// Project-specific [String?] extensions that go beyond what `dartx` provides.
extension CcNullableStringExtension on String? {
  /// Returns `''` when `null`.
  String orEmpty() => this ?? '';
}

/// Project-specific [String] extensions.
extension CcStringExtension on String {
  /// Case-insensitive, diacritic-insensitive containment check
  /// useful for Vietnamese text search.
  bool ctmContain(String request) {
    if (isNullOrEmpty && request.isNullOrEmpty) return true;
    return toLowerCase().removeVietnameseDiacritics.contains(
          request.toLowerCase().removeVietnameseDiacritics,
        );
  }

  /// Strips Vietnamese diacritics for normalised comparison.
  String get removeVietnameseDiacritics {
    var str = this;
    str = str.replaceAll(RegExp('[àáạảãâầấậẩẫăằắặẳẵ]'), 'a');
    str = str.replaceAll(RegExp('[èéẹẻẽêềếệểễ]'), 'e');
    str = str.replaceAll(RegExp('[ìíịỉĩ]'), 'i');
    str = str.replaceAll(RegExp('[òóọỏõôồốộổỗơờớợởỡ]'), 'o');
    str = str.replaceAll(RegExp('[ùúụủũưừứựửữ]'), 'u');
    str = str.replaceAll(RegExp('[ỳýỵỷỹ]'), 'y');
    str = str.replaceAll(RegExp('[đ]'), 'd');
    return str;
  }

  /// Returns `true` when the string looks "empty" in a broad sense
  /// (blank, `"null"`, `"{}"`, `"false"`, `"0"`).
  bool get isEffectivelyEmpty {
    final trimmed = replaceAll(' ', '');
    return ['', 'null', '{}', 'false', '0'].contains(trimmed);
  }

  /// Truncates to [cutoff] characters and appends `'...'`.
  String truncateWithEllipsis({required int cutoff}) {
    return (length <= cutoff) ? this : '${substring(0, cutoff)}...';
  }

  /// Lowercases the first character.
  String lowerFirst() {
    if (isEmpty) return '';
    return '${this[0].toLowerCase()}${substring(1)}';
  }
}

/// Project-specific [int?] extensions.
extension CcNullableIntExtension on int? {
  bool get isNotNullAndNotZero => this != null && this! > 0;

  bool get isNullOrZero => this == null || this! <= 0;

  DateTime? toDateTimeFromMillisecondsSinceEpoch() {
    if (this == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(this!);
  }
}

/// Project-specific [DateTime] extensions.
extension CcDateTimeExtension on DateTime {
  String ctmToString({String? pattern}) {
    final fmt = (pattern == null || pattern.isNullOrEmpty)
        ? CcConstantsDateTime.datetimeFormatPattern
        : pattern;
    return DateFormat(fmt).format(toLocalUtc());
  }

  int ctmGetTime() => millisecondsSinceEpoch;

  DateTime toLocalUtc({String pattern = ''}) => add(Duration.zero);

  DateTime addDay(int day) {
    return _setDateTime(type: DataHelper.addDate, day: day);
  }

  DateTime getStartDate() => _setDateTime(type: DataHelper.startDate);

  DateTime getEndDate() => _setDateTime(type: DataHelper.endDate);

  DateTime _setDateTime({
    int? type,
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    int y = year ?? this.year;
    int mo = month ?? this.month;
    int d = day ?? this.day;
    int h = hour ?? this.hour;
    int mi = minute ?? this.minute;
    int s = second ?? this.second;
    int ms = millisecond ?? this.millisecond;
    int us = microsecond ?? this.microsecond;

    if (type == DataHelper.addDate) {
      y = year == null ? this.year : this.year + year;
      mo = month == null ? this.month : this.month + month;
      d = day == null ? this.day : this.day + day;
      h = hour == null ? this.hour : this.hour + hour;
      mi = minute == null ? this.minute : this.minute + minute;
      s = second == null ? this.second : this.second + second;
      ms = millisecond == null
          ? this.millisecond
          : this.millisecond + millisecond;
      us = microsecond == null
          ? this.microsecond
          : this.microsecond + microsecond;
    }
    if (type == DataHelper.subDate) {
      y = year == null ? this.year : this.year - year;
      mo = month == null ? this.month : this.month - month;
      d = day == null ? this.day : this.day - day;
      h = hour == null ? this.hour : this.hour - hour;
      mi = minute == null ? this.minute : this.minute - minute;
      s = second == null ? this.second : this.second - second;
      ms = millisecond == null
          ? this.millisecond
          : this.millisecond - millisecond;
      us = microsecond == null
          ? this.microsecond
          : this.microsecond - microsecond;
    }
    if (type == DataHelper.startDate) {
      h = 0;
      mi = 0;
      s = 0;
      ms = 0;
      us = 0;
    }
    if (type == DataHelper.endDate) {
      h = 23;
      mi = 59;
      s = 59;
      ms = 59;
      us = 59;
    }
    return DateTime(y, mo, d, h, mi, s, ms, us);
  }
}

/// Project-specific [List?] extensions.
extension CcNullableListExtension on List? {
  List<T?> pluck<T>(Function f) {
    if (isNullOrEmpty) return [];
    return [for (final item in this!) f(item) as T?];
  }

  T? ctmGetMax<T>({required Comparable Function(dynamic) f}) {
    if (isNullOrEmpty) return null;
    return this!.reduce((a, b) => f(a).compareTo(f(b)) >= 0 ? a : b) as T?;
  }

  T? ctmFirstOrDefault<T>({bool Function(dynamic)? f}) {
    if (isNullOrEmpty) return null;
    if (f != null) return this!.firstWhereOrNull((x) => f(x)) as T?;
    return this!.first as T?;
  }

  dynamic ctmSum({Function? f, dynamic defaultValue = 0}) {
    if (isNullOrEmpty) return defaultValue;
    var rs = defaultValue;
    for (final item in this!) {
      rs += f != null ? f(item) : item;
    }
    return rs;
  }

  bool ctmAny({bool Function(dynamic)? f}) {
    if (isNullOrEmpty) return false;
    if (f != null) return ctmFirstOrDefault(f: f) != null;
    return true;
  }

  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

/// Project-specific [double?] extensions.
extension CcNullableDoubleExtension on double? {
  bool get isNotNullAndNotZero => this != null && this! > 0;
}

/// Project-specific [Map?] extensions.
extension CcNullableMapExtension on Map? {
  dynamic ctmKeyDefault(String key) {
    if (this == null) return null;
    if (this!.containsKey(key)) return this![key];
    return null;
  }
}
