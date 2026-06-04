import 'package:equatable/equatable.dart';

/// Pure Domain Entity representing device information.
///
/// This class is part of the Domain layer and has NO dependencies on
/// platform plugins or data-layer implementation details.
class CcDeviceEntity extends Equatable {
  final String? deviceName;
  final String? deviceId;
  final String? osName;
  final String? osVersion;
  final String? appName;
  final String? appVersion;
  final String? packageName;
  final String? model;
  final String? brand;
  final bool? isPhysicalDevice;
  final String deviceInfo;

  const CcDeviceEntity({
    required this.deviceInfo,
    this.deviceName,
    this.deviceId,
    this.osName,
    this.osVersion,
    this.appName,
    this.appVersion,
    this.packageName,
    this.model,
    this.brand,
    this.isPhysicalDevice,
  });

  @override
  List<Object?> get props => [
    deviceInfo,
    deviceName,
    deviceId,
    osName,
    osVersion,
    appName,
    appVersion,
    packageName,
    model,
    brand,
    isPhysicalDevice,
  ];
}
