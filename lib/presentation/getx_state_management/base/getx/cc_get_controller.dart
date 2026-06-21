import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiple_result/multiple_result.dart';

abstract class CcGetController extends GetxController {
  Rx<CcLayoutStatus> layoutStatus = Rx<CcLayoutStatus>(CcLayoutStatus.loading);
  RxString errorMessage = RxString('');

  /// Handles UI rendering based on the current [layoutStatus].
  ///
  /// This widget automatically reacts to changes in [layoutStatus] and
  /// switches between loading, success, empty, and error states.
  Widget multipleLayoutStates({
    Function(CcLayoutStatus? layoutStatus)? onChangeState,
    required Widget Function() onLoading,
    required Widget Function() onSuccess,
    required Widget Function() onEmpty,
    Function()? empty,
    required Widget Function(String code) onError,
  }) {
    onChangeState?.call(layoutStatus.value);

    return Obx(() {
      switch (layoutStatus.value) {
        case CcLayoutStatus.loading:
          return onLoading();
        case CcLayoutStatus.success:
          return onSuccess();
        case CcLayoutStatus.error:
          final message = errorMessage.value != '' ? errorMessage.value : '100';
          return onError(message);
        case CcLayoutStatus.empty:
          return onEmpty();
        case CcLayoutStatus.loadMore:
          return const SizedBox();
        case CcLayoutStatus.refresh:
          return onLoading();
      }
    });
  }

  /// A helper method to fetch data and automatically manage the [layoutStatus].
  ///
  /// - [fetchFunction]: The repository call returning a [Result].
  /// - [targetList]: Optional [RxList] to automatically populate on success.
  ///
  /// Returns the [Result] for further processing if needed.
  Future<Result<List<T>, CcFailure>> ccFetchData<T>({
    required Future<Result<List<T>, CcFailure>> Function() fetchFunction,
    RxList<T>? targetList,
  }) async {
    layoutStatus.value = CcLayoutStatus.loading;
    try {
      final hasInternet = await getIt<CcNetworkHelper>().hasInternet;
      if (!hasInternet) {
        final errorMsg = el.tr(CcLocaleKeys.app_error_network);
        errorMessage.value = errorMsg;
        layoutStatus.value = CcLayoutStatus.error;
        return Error(NetworkFailure(errorMsg));
      }

      final result = await fetchFunction();

      result.when(
        (success) {
          targetList?.assignAll(success);

          if (success.isEmpty) {
            layoutStatus.value = CcLayoutStatus.empty;
          } else {
            layoutStatus.value = CcLayoutStatus.success;
          }
        },
        (error) {
          errorMessage.value = error.message;
          layoutStatus.value = CcLayoutStatus.error;
        },
      );

      return result;
    } catch (e) {
      final errorMsg = e.toString();
      errorMessage.value = errorMsg;
      layoutStatus.value = CcLayoutStatus.error;
      return Error(ServerFailure(errorMsg));
    }
  }
}
