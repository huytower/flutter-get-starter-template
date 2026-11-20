import 'package:domain_features/export_domain_features.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: GuidelineProgressProvider)
class GuidelineProgressProviderImpl implements GuidelineProgressProvider {
  GuidelineController? get _guideline =>
      Get.isRegistered<GuidelineController>()
      ? Get.find<GuidelineController>()
      : null;

  @override
  Future<void> completeTask(String taskId) async =>
      _guideline?.completeTask(taskId);

  @override
  Future<void> setInvestmentCreated() async =>
      _guideline?.setInvestmentCreated();

  @override
  Future<void> setLiabilityCreated() async => _guideline?.setLiabilityCreated();
}
