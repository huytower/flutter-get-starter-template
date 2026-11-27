import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'prj_guideline_badge.dart';

/// The guideline dot + hint bubble placed at the top right of a form's
/// direction toggle (Investment Contribute/Return, Borrow Borrowed/Repay).
///
/// Use it as a **non-positioned** child of the toggle's `Stack` (never inside
/// `Positioned` with `Clip.none`): the Stack then grows to hold the bubble.
/// Anything painted outside a Stack's bounds is not hit-tested, which made
/// the bubble's close "X" untappable.
class PrjGuidelineToggleBadge extends StatelessWidget {
  const PrjGuidelineToggleBadge({super.key, required this.label});

  /// Text of the hint bubble (the current guideline step description).
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.respDim(15),
        right: context.respDim(50),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: PrjGuidelineBadge(
          size: context.respDim(6),
          label: label,
          labelAbove: false,
        ),
      ),
    );
  }
}
