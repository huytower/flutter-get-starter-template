import 'package:hive_ce/hive_ce.dart';

/// Writes an upload's outcome back to its box without undoing what happened to
/// the record while it was uploading (offline, that can take a long time).
abstract final class UploadWriteBack {
  /// Stores [mark] of the record now under [key]. A record deleted meanwhile
  /// stays deleted; one changed meanwhile (for example soft-deleted) goes
  /// through [keepPending], so the next pass uploads the change. [uploaded]
  /// is the version that was sent.
  static Future<void> save<T>(
    Box<dynamic> box,
    String key,
    T uploaded, {
    required T Function(T current) mark,
    required T Function(T marked) keepPending,
  }) async {
    final current = box.get(key) as T?;
    if (current == null) return;
    final marked = mark(current);
    await box.put(
      key,
      identical(current, uploaded) ? marked : keepPending(marked),
    );
  }
}
