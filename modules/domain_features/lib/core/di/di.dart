import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/profile/presentation/get_x/profile_controller.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [
    FirestoreSyncService,
  ],
)
void initMicroPackage() {
  Get.lazyPut(() => getIt<ProfileController>());
}
