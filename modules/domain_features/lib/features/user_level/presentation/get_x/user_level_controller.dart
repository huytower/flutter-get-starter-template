import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user_level_status_entity.dart';
import '../../domain/usecases/get_user_level_status_usecase.dart';

/// Cross-cutting, app-wide singleton (not tied to any one page) exposing the
/// current LV1/LV2/LV3 unlock state. Consumers (Transaction, Budget
/// Allocation, Profile) read [status] reactively via `Obx` and call
/// [refresh] whenever an action could have moved the needle (a reconciliation
/// completes, a budget is created, or the relevant tab is re-entered).
@lazySingleton
class UserLevelController {
  UserLevelController(this._getUserLevelStatus);

  final GetUserLevelStatusUseCase _getUserLevelStatus;

  final Rx<UserLevelStatusEntity> status = const UserLevelStatusEntity.initial()
      .obs;

  Future<void> refresh() async {
    final result = await _getUserLevelStatus.call();
    result.when((success) => status.value = success, (_) {});
  }
}
