import 'package:flutter/foundation.dart';

/// TEMPORARY diagnostic tracer for the Firestore -> Hive -> UI chain.
///
/// Emits one greppable line per event, prefixed with a monotonic offset from
/// the first traced call so the ordering between the background pull and the
/// page render is unambiguous in the debug console (plain `.Log()` lines have
/// no reliable relative timestamp across sources).
///
/// Search the console for `SYNC_TRACE` to see the whole sequence.
class SyncTrace {
  SyncTrace._();

  static final Stopwatch _stopwatch = Stopwatch()..start();

  static void log(String message) {
    if (!kDebugMode) return;
    final ms = _stopwatch.elapsedMilliseconds.toString().padLeft(6);
    final wall =
        DateTime.now().toIso8601String().substring(11, 23); // HH:mm:ss.mmm
    debugPrint('[SYNC_TRACE +$ms ms | $wall] $message');
  }
}
