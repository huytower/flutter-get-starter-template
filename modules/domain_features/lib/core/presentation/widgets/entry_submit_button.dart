import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class EntrySubmitButton extends StatelessWidget {
  final String text;
  final bool hasSubmitting;
  final bool hasEnabled;
  final VoidCallback onTap;
  final Color activeColor;
  final Widget? badge;

  /// Fraction of the available width the button occupies. Defaults to the
  /// full-size call-to-action used by the transaction forms.
  final double widthFactor;

  /// Button height. Defaults to `context.respDim(40)` when omitted.
  final double? height;

  /// Label style. Defaults to `context.ccTextTheme.titleMedium` when omitted.
  final TextStyle? textStyle;

  /// Optional decorative icon rendered to the left of [text]. It is part of the
  /// button's label — it is not separately tappable, the whole button is, and
  /// it always inherits the label's foreground colour.
  final IconData? leadingIcon;

  /// Base size for [leadingIcon], fed through `context.respIconSize`.
  final double leadingIconSize;

  /// Optional fill painted instead of the solid [activeColor] while the button
  /// is enabled (e.g. the metallic gold of the Investment form).
  final Gradient? gradient;

  /// Label / icon colour used on top of [gradient]. Defaults to `onPrimary`.
  final Color? gradientForegroundColor;

  const EntrySubmitButton({
    super.key,
    required this.text,
    required this.hasSubmitting,
    required this.hasEnabled,
    required this.onTap,
    required this.activeColor,
    this.badge,
    this.widthFactor = 0.6,
    this.height,
    this.textStyle,
    this.leadingIcon,
    this.leadingIconSize = 20,
    this.gradient,
    this.gradientForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final baseStyle = textStyle ?? context.ccTextTheme.titleMedium;
    final borderRadius = BorderRadius.circular(12);
    final useGradient = gradient != null && hasEnabled;
    final foreground = useGradient
        ? gradientForegroundColor ?? scheme.onPrimary
        : scheme.onPrimary;
    return Center(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: height ?? context.respDim(40),
              decoration: useGradient
                  ? BoxDecoration(
                      gradient: gradient,
                      borderRadius: borderRadius,
                    )
                  : null,
              child: ElevatedButton(
                onPressed: hasEnabled && !hasSubmitting ? onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: useGradient
                      ? Colors.transparent
                      : activeColor,
                  disabledBackgroundColor: useGradient
                      ? Colors.transparent
                      : null,
                  shadowColor: useGradient ? Colors.transparent : null,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.respPadding(CcPaddingParams.SPACE_SM),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                ),
                child: hasSubmitting
                    ? SizedBox(
                        width: context.respDim(20),
                        height: context.respDim(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(foreground),
                        ),
                      )
                    : _buildLabel(context, foreground, baseStyle),
              ),
            ),
            if (badge != null)
              Positioned(bottom: -10, right: -10, child: badge!),
          ],
        ),
      ),
    );
  }

  /// Builds the `[leadingIcon] [text]` label row.
  ///
  /// Only the text is wrapped in a scale-down [FittedBox], so a narrow
  /// [widthFactor] (or a longer translation) shrinks the label while
  /// [leadingIcon] always renders at its declared size.
  ///
  /// Plain [Text] is used rather than `CcText` because `CcText` forces an
  /// [Align] around its content, which fights the [Flexible]/[FittedBox]
  /// sizing here. Typography still comes from `context.ccTextTheme` via
  /// [baseStyle], so the design-system chain of truth is unbroken.
  Widget _buildLabel(
    BuildContext context,
    Color foreground,
    TextStyle? baseStyle,
  ) {
    final label = Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseStyle?.copyWith(
            color: foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(
            leadingIcon,
            size: context.respIconSize(baseSize: leadingIconSize),
            color: foreground,
          ),
          const CcSpaceXS(),
        ],
        label,
      ],
    );
  }
}
