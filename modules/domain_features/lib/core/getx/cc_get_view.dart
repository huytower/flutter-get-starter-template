import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../di/di.dart';
import '../presentation/widgets/prj_page_background.dart';
import 'cc_get_controller.dart';

/// Base class for GetX views with built-in layout state management.
///
/// ⚠️ Do NOT override the standard Flutter [build()] method.
/// The [build()] method is already implemented here and handles the complete
/// view structure including scaffolding, layout states, and error handling.
///
/// **Override [buildContent()] instead** to provide your main content widget.
///
/// Example:
/// ```dart
/// class MyView extends CcGetView<MyController> {
///   @override
///   Widget? buildContent(BuildContext context) {
///     return Text('My Content'); // Your content here
///   }
/// }
/// ```
abstract class CcGetView<T extends CcGetController> extends GetView<T>
    with CcViewConfigMixin {
  //----------------------------------------------------------------------------
  const CcGetView({super.key});

  //----------------------------------------------------------------------------
  /// Ensures the controller is registered in GetX before the view is built.
  ///
  /// Registered as [permanent] so tab controllers survive bottom-navigation
  /// switches (auto_route pops the page) instead of being disposed and
  /// re-created on every return.
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<T>()) {
      Get.put(getIt<T>(), permanent: true);
    }
    return Obx(() => super.build(context));
  }

  //----------------------------------------------------------------------------
  // GetX-specific implementation of layoutStatus with reactivity
  @override
  CcLayoutStatus get layoutStatus => controller.layoutStatus.value;

  @override
  String get errorMessage => controller.errorMessage.value;

  //----------------------------------------------------------------------------
  /// Every page shares the standard brand-gradient background. Override to
  /// return [body] untouched (or a custom backdrop) for a page that paints its
  /// own.
  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) =>
      PrjPageBackground(child: body);

  //----------------------------------------------------------------------------
  @override
  void onRetry(BuildContext context) {
    controller.onInit();
  }
}
