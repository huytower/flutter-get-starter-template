/// Date and time formatting utilities.
abstract final class CcDateTimeHelper {
  CcDateTimeHelper._();

  /// Converts a [Duration] to `MM:SS` or `H:MM:SS`.
  static String durationToTimeString(Duration duration) {
    final hours = duration.inHours != 0 ? '${duration.inHours}:' : '';
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(hours.isEmpty ? 1 : 2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return hours.isEmpty ? '$minutes:$seconds' : '$hours$minutes:$seconds';
  }

  /// Parses `HH:MM:SS` or `MM:SS` into a [Duration].
  ///
  /// Throws [FormatException] when the format is invalid.
  static Duration timeStringToDuration(String timeString) {
    final parts = timeString.split(':');

    if (parts.isEmpty || parts.length > 3) {
      throw const FormatException(
        'Invalid time string format. Expected HH:MM:SS or MM:SS',
      );
    }

    var hours = 0;
    var minutes = 0;
    var seconds = 0;

    if (parts.length == 3) {
      hours = int.tryParse(parts[0]) ?? 0;
      minutes = int.tryParse(parts[1]) ?? 0;
      seconds = double.tryParse(parts[2])?.round() ?? 0;
    } else if (parts.length == 2) {
      minutes = int.tryParse(parts[0]) ?? 0;
      seconds = double.tryParse(parts[1])?.round() ?? 0;
    } else {
      seconds = double.tryParse(parts[0])?.round() ?? 0;
    }

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  /// Current UTC timestamp in microseconds since epoch.
  static int utcNowMicrosecondsSinceEpoch() =>
      DateTime.now().toUtc().microsecondsSinceEpoch;

  /// Converts [dateTime] to UTC.
  static DateTime toUtc(DateTime dateTime) =>
      dateTime.isUtc ? dateTime : dateTime.toUtc();

  @Deprecated('Use toUtc')
  static DateTime getUTCLocal({required DateTime dtm, String pattern = ''}) =>
      toUtc(dtm);
}
