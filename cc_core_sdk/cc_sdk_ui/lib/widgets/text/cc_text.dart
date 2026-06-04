import 'package:flutter/material.dart';

import '../../core/config/tokens/cc_typography_params.dart';
import '../../core/extensions/cc_context_extension.dart';
import '../../core/extensions/common/cc_responsive_extension.dart';

class CcText extends StatelessWidget {
  final String? text;
  final Alignment? align;
  final Color? color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize, heightLine, marginLeft, marginRight;
  final TextAlign? textAlign;
  final TextStyle? textStyle;

  const CcText(
    this.text, {
    super.key,
    this.align,
    this.color,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.heightLine,
    this.marginLeft,
    this.marginRight,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = context.ccTextTheme.bodyMedium;

    return Align(
      alignment: align ?? Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: context.respPadding(marginLeft ?? 0),
          right: context.respPadding(marginRight ?? 0),
        ),
        child: RichText(
          textAlign: textAlign ?? TextAlign.left,
          maxLines: maxLines ?? 1,
          overflow: overflow ?? TextOverflow.ellipsis,
          text: TextSpan(
            text: text ?? '',
            style: textStyle ?? _getTextStyle(context, defaultStyle),
          ),
        ),
      ),
    );
  }

  TextStyle _getTextStyle(BuildContext context, TextStyle? baseStyle) {
    final style = baseStyle ?? const TextStyle();
    return style.copyWith(
      height: heightLine ?? 1.2,
      color: color,
      fontSize: context.respFontSize(fontSize ?? CcTypographyParams.bodyMedium),
      fontWeight: fontWeight ?? CcTypographyParams.regular,
      fontStyle: fontStyle ?? FontStyle.normal,
    );
  }
}
