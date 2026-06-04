import 'package:flutter/material.dart';

/// loading|progress ui
/// show in splash presentation page
/// Note: This version uses CircularProgressIndicator to avoid Lottie dependency in cc_sdk_ui
/// If Lottie is required, add lottie package to cc_sdk_ui/pubspec.yaml
class SplashLoadingWidget extends StatelessWidget {
  const SplashLoadingWidget({
    Key? key,
    this.isJsonResId = true,
    required this.resId,
    this.width = 115,
  }) : super(key: key);

  final bool isJsonResId;

  final double width;
  final String resId;

  @override
  Widget build(BuildContext context) => isJsonResId
      ? SizedBox(
          height: width,
          width: width,
          child: const CircularProgressIndicator(),
        )
      : const SizedBox();
}
