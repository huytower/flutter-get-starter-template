import 'package:flutter/cupertino.dart';

/// How to use?
/// ex.
///    TextSpansWidget([
///      WidgetUtil.getTextSpanRoboto(
///        controller.sectionLogin,
///        fontSize: 19.5,
///        heightLine: 32 / 19.5,
///      ),
///    ])
class CcTextSpans extends StatelessWidget {
  const CcTextSpans(this.spans, {Key? key, this.textAlign = TextAlign.left})
    : super(key: key);

  final List<InlineSpan> spans;

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) => RichText(
    textAlign: textAlign,
    text: TextSpan(children: spans),
  );
}
