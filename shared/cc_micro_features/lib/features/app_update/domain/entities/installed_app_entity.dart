import 'package:equatable/equatable.dart';

import 'app_version_entity.dart';

/// The app as installed on this device.
class InstalledAppEntity extends Equatable {
  const InstalledAppEntity({
    required this.version,
    required this.packageName,
    required this.hasStoreDistributed,
  });

  final AppVersionEntity version;

  /// Android applicationId / iOS bundle id.
  final String packageName;

  /// Whether this platform updates through a store (Android/iOS, not web or
  /// desktop). A forced update is only shown where there is a store to go to.
  final bool hasStoreDistributed;

  @override
  List<Object?> get props => [version, packageName, hasStoreDistributed];
}
