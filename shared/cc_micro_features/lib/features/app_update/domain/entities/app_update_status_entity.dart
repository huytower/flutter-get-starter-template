import 'package:equatable/equatable.dart';

import 'app_version_entity.dart';

/// Outcome of an update check.
sealed class AppUpdateStatusEntity extends Equatable {
  const AppUpdateStatusEntity();
}

/// Nothing to do: forced update is off, no minimum is set, or the installed
/// version already meets it.
final class AppUpdateNotRequired extends AppUpdateStatusEntity {
  const AppUpdateNotRequired();

  @override
  List<Object?> get props => const [];
}

/// The installed version is below the configured minimum and must update.
final class AppUpdateRequired extends AppUpdateStatusEntity {
  const AppUpdateRequired({
    required this.currentVersion,
    required this.minimumVersion,
  });

  final AppVersionEntity currentVersion;
  final AppVersionEntity minimumVersion;

  @override
  List<Object?> get props => [currentVersion, minimumVersion];
}
