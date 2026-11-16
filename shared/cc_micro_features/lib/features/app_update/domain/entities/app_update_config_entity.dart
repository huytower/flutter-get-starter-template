import 'package:equatable/equatable.dart';

/// Update policy supplied by the host app (see `AppUpdateConfigRepository`).
class AppUpdateConfigEntity extends Equatable {
  const AppUpdateConfigEntity({
    required this.isForce,
    this.minimumVersion,
    this.iosAppStoreId,
    this.androidPackageName,
  });

  /// Turns the forced update on. When `false` nothing is ever blocked.
  final bool isForce;

  /// Installed versions strictly below this one must update, written as
  /// `x.y.z` or `x.y.z+build`. Empty or invalid means "no minimum".
  final String? minimumVersion;

  /// Numeric App Store id (the digits of `id123456789`), needed on iOS.
  final String? iosAppStoreId;

  /// Play Store package; defaults to the installed app's own package.
  final String? androidPackageName;

  @override
  List<Object?> get props => [
    isForce,
    minimumVersion,
    iosAppStoreId,
    androidPackageName,
  ];
}
