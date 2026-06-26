import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Shows a snackbar indicating that the user should press back again to exit.
///
/// Uses standard tokens from [cc_sdk_ui] for consistent styling.
void showDoubleBackPressSnackBar(BuildContext context, String message) {
  CcSnackBarHelper.showSnackBar(
    context: context,
    message: message,
    duration: const Duration(seconds: 1),
    backgroundColor: context.ccColorScheme.inverseSurface,
    textColor: context.ccColorScheme.onInverseSurface,
    fontWeight: FontWeight.w500,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(CcCircularParams.RADIUS_MD),
    ),
    margin: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_SM)),
    elevation: 6,
  );
}
