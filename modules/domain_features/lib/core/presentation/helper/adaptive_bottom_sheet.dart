import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Shows a modal bottom sheet that stays a sensible size on tablets.
///
/// Phones (window < 600 dp) are unchanged. From a small tablet up, Material's
/// default 640 dp cap is too wide for short, list-like sheets, so the sheet is
/// narrowed to [tabletMaxWidth] (centred); on every size it is kept clear of
/// the system bars. Pass a larger [tabletMaxWidth] for sheets that lay content
/// out in columns.
///
/// Defaults match the project's custom sheets (transparent background, content
/// draws its own surface). Pass `backgroundColor: null` to use the theme's
/// sheet colour.
Future<T?> showAdaptiveBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double tabletMaxWidth = 480,
  Color? backgroundColor = Colors.transparent,
  ShapeBorder? shape,
  bool hasScrollControlled = true,
  bool hasDismissible = true,
}) {
  final hasTablet = CcWindowSizeClass.of(
    context,
  ).hasAtLeast(CcWindowSizeClass.medium);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: hasScrollControlled,
    useSafeArea: true,
    isDismissible: hasDismissible,
    backgroundColor: backgroundColor,
    shape: shape,
    constraints: hasTablet ? BoxConstraints(maxWidth: tabletMaxWidth) : null,
    builder: builder,
  );
}
