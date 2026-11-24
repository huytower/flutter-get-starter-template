import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// An app version such as `1.2.3` or `1.2.3+25` (`+25` is the build number).
///
/// Comparison is numeric per segment, so `1.10.0` is newer than `1.9.0`, and
/// missing segments count as `0` (`1.2` equals `1.2.0`). The build number only
/// breaks a tie when **both** sides carry one: a minimum of `1.2.0` ignores the
/// installed build number, a minimum of `1.2.0+30` also requires build >= 30.
class AppVersionEntity extends Equatable
    implements Comparable<AppVersionEntity> {
  const AppVersionEntity({required this.segments, this.buildNumber});

  /// Numeric segments, e.g. `[1, 2, 3]` for `1.2.3`.
  final List<int> segments;

  /// Build number after `+`, or `null` when the version has none.
  final int? buildNumber;

  /// Parses [raw]; returns `null` when it is empty or not a version.
  ///
  /// Accepts an optional leading `v` and ignores a pre-release suffix
  /// (`1.2.3-beta` reads as `1.2.3`).
  static AppVersionEntity? tryParse(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;

    final buildSplit = value.split('+');
    if (buildSplit.length > 2) return null;

    var core = buildSplit.first.trim();
    if (core.startsWith('v') || core.startsWith('V')) core = core.substring(1);
    core = core.split('-').first;
    if (core.isEmpty) return null;

    final segments = <int>[];
    for (final segment in core.split('.')) {
      final number = int.tryParse(segment.trim());
      if (number == null || number < 0) return null;
      segments.add(number);
    }

    int? buildNumber;
    if (buildSplit.length == 2) {
      buildNumber = int.tryParse(buildSplit[1].trim());
      if (buildNumber == null || buildNumber < 0) return null;
    }

    return AppVersionEntity(
      segments: List.unmodifiable(segments),
      buildNumber: buildNumber,
    );
  }

  @override
  int compareTo(AppVersionEntity other) {
    final length = math.max(segments.length, other.segments.length);
    for (var i = 0; i < length; i++) {
      final mine = i < segments.length ? segments[i] : 0;
      final theirs = i < other.segments.length ? other.segments[i] : 0;
      if (mine != theirs) return mine.compareTo(theirs);
    }
    final myBuild = buildNumber;
    final theirBuild = other.buildNumber;
    if (myBuild != null && theirBuild != null) {
      return myBuild.compareTo(theirBuild);
    }
    return 0;
  }

  /// Whether this version is strictly older than [other].
  bool hasLowerThan(AppVersionEntity other) => compareTo(other) < 0;

  @override
  String toString() {
    final build = buildNumber;
    final core = segments.join('.');
    return build == null ? core : '$core+$build';
  }

  @override
  List<Object?> get props => [segments, buildNumber];
}
