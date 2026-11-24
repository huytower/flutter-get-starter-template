import 'package:hive_ce/hive_ce.dart';
import 'package:json_annotation/json_annotation.dart';

import '../prj_hive_box.dart';

part 'prj_device_info.g.dart';

///
///[example update]-------------------------------------------------------------
///   PrjAppStorage.instance.apply((_this) {
///       _this.token = "token_123";
///       _this.uuid = "uuid_123";
///
///       _this.save();
///   });
///[example logger]-------------------------------------------------------------
///   PrjAppStorage.instance.Log();
///
///

/// width, height, device name, imei, id...
@JsonSerializable()
@HiveType(typeId: PrjHiveBox.DEVICE_TYPE_ID)
class PrjDeviceInfo extends HiveObject {
  static late PrjDeviceInfo instance;

  static Future<PrjDeviceInfo?> register() async {
    Hive.registerAdapter(PrjDeviceInfoAdapter());
    Box<PrjDeviceInfo> box = await Hive.openBox<PrjDeviceInfo>(
      PrjHiveBox.DEVICE_BOX_NAME,
    );
    PrjDeviceInfo? model = box.get(PrjHiveBox.keyDefault);
    if (model == null) {
      model = PrjDeviceInfo();
      box.put(PrjHiveBox.keyDefault, model);
    }
    instance = model;
    return model;
  }

  @HiveField(0)
  String? appVersion;

  @HiveField(1)
  String? deviceId;

  @HiveField(2)
  String? serialNumber;

  /// NOTICE : assert this value can not null after started from app_runner.dart
  /// otherwise, show error log in app tracking log
  @HiveField(3)
  double? deviceWidth;

  /// NOTICE : assert this value can not null after started from app_runner.dart
  /// otherwise, show error log in app tracking log
  @HiveField(4)
  double? deviceHeight;

  PrjDeviceInfo({
    this.appVersion,
    this.deviceId,
    this.serialNumber,
    this.deviceWidth,
    this.deviceHeight,
  });

  Map<String, dynamic> toJson() => _$PrjDeviceInfoToJson(this);
}
