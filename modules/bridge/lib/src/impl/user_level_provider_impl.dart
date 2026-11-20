import 'package:domain_features/export_domain_features.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UserLevelProvider)
class UserLevelProviderImpl implements UserLevelProvider {
  UserLevelProviderImpl(this._controller);

  final UserLevelController _controller;

  // Reads `.value`, so an enclosing `Obx` still subscribes to the change.
  @override
  UserLevelStatusEntity get status => _controller.status.value;

  @override
  Future<void> refresh() => _controller.refresh();
}
