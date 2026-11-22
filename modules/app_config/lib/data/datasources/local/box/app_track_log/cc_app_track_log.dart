import 'package:hive_ce/hive_ce.dart';
import 'package:json_annotation/json_annotation.dart';

import '../cc_hive_box.dart';

part 'cc_app_track_log.g.dart';

///
///[example update]-------------------------------------------------------------
///   CcAppStorage.instance.apply((_this) {
///       _this.token = "token_123";
///       _this.uuid = "uuid_123";
///
///       _this.save();
///   });
///[example logger]-------------------------------------------------------------
///   CcAppStorage.instance.Log();
///
///

@JsonSerializable()
@HiveType(typeId: CcHiveBox.APP_TRACK_LOG_TYPE_ID)
class CcAppTrackLog extends HiveObject {
  static late CcAppTrackLog instance;

  static Future<CcAppTrackLog?> register() async {
    Hive.registerAdapter(CcAppTrackLogAdapter());
    Box<CcAppTrackLog> box = await Hive.openBox<CcAppTrackLog>(
      CcHiveBox.TRACK_LOG_BOX_NAME,
    );
    CcAppTrackLog? model = box.get(CcHiveBox.keyDefault);
    if (model == null) {
      model = CcAppTrackLog();
      box.put(CcHiveBox.keyDefault, model);
    }
    instance = model;
    return model;
  }

  @HiveField(0)
  List<String>? msg;

  @HiveField(1)
  String? tag;

  CcAppTrackLog({this.msg, this.tag});

  Map<String, dynamic> toJson() => _$CcAppTrackLogToJson(this);
}
