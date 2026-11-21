import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'package:domain_features/core/presentation/widgets/entry_form_container.dart';

/// Two-column layout shared by the Transaction-page forms (expense, income,
/// investment, liability, lend) on a tablet held sideways.
///
/// - Left (3/5): [leading] (direction toggle, category / asset selector),
///   then [details] (date + note, always open) in a form card.
/// - Right (2/5): [right] (amount, source wallet, extra fields, submit) in a
///   form card.
///
/// Use [shouldUse] to pick it; phones (portrait only) and portrait tablets
/// keep each form's single column.
class EntryFormTwoColumn extends StatelessWidget {
  const EntryFormTwoColumn({
    super.key,
    required this.leading,
    required this.right,
    this.details,
  });

  final List<Widget> leading;
  final Widget? details;
  final List<Widget> right;

  /// Landscape window at least 600 dp wide (small tablet and up).
  static bool shouldUse(BuildContext context) => CcTwoColumn.shouldUse(context);

  /// The columns span up to this width (instead of the 840 dp content column)
  /// so the extra room of a landscape tablet is actually used.
  static const double maxWidth = 1200;

  @override
  Widget build(BuildContext context) {
    final gap = context.respPadding(CcPaddingParams.PAGE_SM);
    final details = this.details;
    // Small (~7") tablet: even split, the 3:2 right column is too narrow.
    final even = CcTwoColumn.isSmallTablet(context);
    return CcContentInset(
      maxWidth: maxWidth,
      child: CcContentPadding(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: even ? 1 : 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...leading,
                  if (details != null) ...[
                    const CcSpaceSM(),
                    Padding(
                      padding: EdgeInsets.only(left: gap),
                      child: EntryFormContainer(child: details),
                    ),
                  ],
                  const CcSpaceMD(),
                ],
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              flex: even ? 1 : 2,
              child: Padding(
                padding: EdgeInsets.only(right: gap),
                child: EntryFormContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: right,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
