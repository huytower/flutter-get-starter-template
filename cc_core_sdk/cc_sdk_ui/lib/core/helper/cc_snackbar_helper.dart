import 'package:flutter/material.dart';

import '../extensions/cc_context_extension.dart';
import '../extensions/common/cc_responsive_extension.dart';

/// Utility class for showing snackbars with consistent styling and behavior
class CcSnackBarHelper {
  /// Shows a snackbar with the given parameters
  ///
  /// [context] - The build context
  /// [message] - The message to display
  /// [duration] - How long the snackbar should be visible (default: 1.3s)
  /// [backgroundColor] - Background color of the snackbar
  /// [textColor] - Text color (default: theme onSurface)
  /// [actionLabel] - Optional action button label
  /// [onActionPressed] - Callback when action button is pressed
  /// [onDismissed] - Callback when snackbar is dismissed
  /// Receives a [SnackBarClosedReason] indicating how the snackbar was dismissed
  /// [shape] - Shape of the snackbar (default: null)
  /// [margin] - Margin around the snackbar (default: 8.0)
  /// [elevation] - Elevation of the snackbar (default: null)
  /// [fontWeight] - Font weight of the text (default: normal)
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    String? actionLabel,
    VoidCallback? onActionPressed,
    void Function(SnackBarClosedReason reason)? onDismissed,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    double? elevation,
    FontWeight? fontWeight,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: context.ccTextTheme.bodyLarge?.copyWith(
          color: textColor ?? context.ccColorScheme.onSurface,
          height: 1.2,
          fontWeight: fontWeight ?? FontWeight.normal,
        ),
      ),
      backgroundColor: backgroundColor ?? context.ccColorScheme.surface,
      duration: duration ?? const Duration(milliseconds: 1300),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onActionPressed ?? () {},
              textColor:
                  textColor?.withOpacity(0.8) ??
                  context.ccColorScheme.primary.withOpacity(0.8),
            )
          : null,
      onVisible: () {
        // Optional: Add any onVisible callbacks here
      },
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      margin: margin ?? EdgeInsets.all(context.respPadding(8.0)),
      shape: shape,
      elevation: elevation,
    );

    // Show the snackbar
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar).closed.then((reason) {
        if (onDismissed != null) {
          onDismissed(reason);
        }
      });
  }

  /// Shows a snackbar with default error styling
  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showSnackBar(
      context: context,
      message: message,
      duration: duration,
      backgroundColor: context.ccColorScheme.error,
      textColor: context.ccColorScheme.onError,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  /// Shows a snackbar with default success styling
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showSnackBar(
      context: context,
      message: message,
      duration: duration,
      backgroundColor: context.ccColorScheme.primary,
      textColor: context.ccColorScheme.onPrimary,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
}
