import 'dart:async';

/// Throttles rapid repeated calls to a callback.
abstract final class CcThrottleHelper {
  CcThrottleHelper._();

  /// Returns a function that invokes [callback] at most once per [duration].
  static void Function() debounce(
    void Function() callback, {
    required Duration duration,
  }) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(duration, callback);
    };
  }

  /// Returns a function that invokes [callback] at most once per [duration]
  /// (leading edge).
  static void Function() throttle(
    void Function() callback, {
    required Duration duration,
  }) {
    Timer? timer;
    return () {
      if (timer?.isActive ?? false) return;
      timer = Timer(duration, () {});
      callback();
    };
  }
}
