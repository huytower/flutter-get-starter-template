import 'package:hive_ce/hive_ce.dart';
import 'package:json_annotation/json_annotation.dart';

import '../prj_hive_box.dart';

part 'prj_app_track_log.g.dart';

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

@JsonSerializable()
@HiveType(typeId: PrjHiveBox.APP_TRACK_LOG_TYPE_ID)
class PrjAppTrackLog extends HiveObject {
  static late PrjAppTrackLog instance;

  static Future<PrjAppTrackLog?> register() async {
    Hive.registerAdapter(PrjAppTrackLogAdapter());
    Box<PrjAppTrackLog> box = await Hive.openBox<PrjAppTrackLog>(
      PrjHiveBox.TRACK_LOG_BOX_NAME,
    );
    PrjAppTrackLog? model = box.get(PrjHiveBox.keyDefault);
    if (model == null) {
      model = PrjAppTrackLog();
      box.put(PrjHiveBox.keyDefault, model);
    }
    instance = model;
    return model;
  }

  @HiveField(0)
  List<String>? msg;

  @HiveField(1)
  String? tag;

  PrjAppTrackLog({this.msg, this.tag});

  Map<String, dynamic> toJson() => _$PrjAppTrackLogToJson(this);
}
