/// Centralizes local-notification ids so the audit, cloud-backup, and loan
/// reminder features can never collide with each other. Fixed ids stay in a
/// tiny low range; loan reminder ids are hash-derived and offset well past
/// it, so the two ranges are disjoint by construction (no need to track a
/// shared registry).
class ReminderIds {
  ReminderIds._();

  static const int auditApproaching = 1;
  static const int auditDue = 2;
  static const int cloudBackup = 3;

  /// Stable id for the [index]-th reminder (installment or lump-sum
  /// milestone) belonging to liability [liabilityId] — derived from the
  /// liability id so it can be recomputed and cancelled later without
  /// tracking ids separately.
  static int liabilityReminder(String liabilityId, int index) =>
      1000 + (_fnv1a32('$liabilityId#$index') & 0x0fffffff);

  /// Stable id for budget [budgetId] crossing warning [tier] ("near"/"over").
  /// Hash-derived like [loanReminder], but with bit 30 forced on so its
  /// range can never collide with [loanReminder]'s (which tops out well
  /// below that bit) — true disjointness by construction, without touching
  /// the existing loan formula.
  static int budgetThreshold(String budgetId, String tier) =>
      0x40000000 | (_fnv1a32('$budgetId#$tier') & 0x0fffffff);

  /// FNV-1a (32-bit) — used instead of [String.hashCode], which is not a
  /// documented-stable algorithm across Dart/Flutter SDK versions. An SDK
  /// upgrade changing hashCode's implementation would silently orphan every
  /// previously-scheduled loan reminder (they'd never be cancellable or
  /// replaceable by id again). FNV-1a's bit pattern is fixed by spec, so ids
  /// computed today stay reproducible on any future SDK.
  static int _fnv1a32(String input) {
    const fnvPrime = 0x01000193;
    var hash = 0x811c9dc5;
    for (final byte in input.codeUnits) {
      hash ^= byte;
      hash = (hash * fnvPrime) & 0xffffffff;
    }
    return hash;
  }
}
