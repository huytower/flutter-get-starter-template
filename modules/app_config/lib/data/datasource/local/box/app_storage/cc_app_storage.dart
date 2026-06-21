import 'dart:async';

import 'package:data/data/models/user/res_user.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:json_annotation/json_annotation.dart';

import '../cc_hive_box.dart';

part 'cc_app_storage.g.dart';

///
///[example update]-------------------------------------------------------------
///   CcAppStorage.instance.accessToken = "token_123";
///   CcAppStorage.instance.userRole = "admin";
///   CcAppStorage.instance.save();
///
///[example logger]-------------------------------------------------------------
///   CcAppStorage.instance.Log();
///

@JsonSerializable()
@HiveType(typeId: CcHiveBox.APP_STORAGE_TYPE_ID)
class CcAppStorage extends HiveObject {
  static late CcAppStorage instance;

  static Future<CcAppStorage?> register() async {
    Hive.registerAdapter(CcAppStorageAdapter());
    Box<CcAppStorage> box = await Hive.openBox<CcAppStorage>(
      CcHiveBox.APP_BOX_NAME,
    );
    final model = box.get(CcHiveBox.keyDefault) ?? CcAppStorage();

    if (!box.containsKey(CcHiveBox.keyDefault)) {
      await box.put(CcHiveBox.keyDefault, model);
    }

    instance = model;
    return model;
  }

  @HiveField(0)
  String? accessToken;

  @HiveField(1)
  String? fcmToken;

  @HiveField(2)
  String? gpsLocation;

  @HiveField(3)
  String? userRole;

  @HiveField(4)
  String? dashboardData;

  CcAppStorage({
    this.accessToken,
    this.fcmToken,
    this.gpsLocation,
    this.userRole,
    this.dashboardData,
  });

  ///
  ResUser? user = ResUser();
}
