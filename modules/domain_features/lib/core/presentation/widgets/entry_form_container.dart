import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// The tinted card holding a form's fields. On wide windows it is capped at
/// the content width ([CcContentPadding]); carousels inside it scroll within
/// the card.
class EntryFormContainer extends StatelessWidget {
  const EntryFormContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return CcContentPadding(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withAlpha(5),
          borderRadius: context.brLg,
          border: Border.all(
            color: scheme.onSurface.withOpacity(0.01),
            width: context.respDim(1),
          ),
        ),
        child: CcPadding(child, 6, 12, 12, 6),
      ),
    );
  }
}
