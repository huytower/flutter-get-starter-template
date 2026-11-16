import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';

/// Body of an auth card (login, phone number, OTP): the brand header (logo,
/// title) and the form.
///
/// Phones and portrait tablets stack them in one column, exactly as before.
/// On a landscape tablet ([CcTwoColumn.shouldUse]) they sit side by side —
/// header on the left, form on the right — so the card is wide instead of tall
/// and nothing is pushed below the fold.
class AuthTwoColumnBody extends StatelessWidget {
  const AuthTwoColumnBody({
    super.key,
    required this.header,
    required this.form,
  });

  final List<Widget> header;
  final List<Widget> form;

  /// Card width to give `CcGradientCardLayout` when the two columns are shown;
  /// null otherwise (the card keeps its own width).
  static double? cardMaxWidth(BuildContext context) =>
      CcTwoColumn.shouldUse(context) ? 1000 : null;

  @override
  Widget build(BuildContext context) {
    if (!CcTwoColumn.shouldUse(context)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [...header, ...form],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: header),
        ),
        SizedBox(width: context.respPadding(CcPaddingParams.PAGE_XL)),
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: form),
        ),
      ],
    );
  }
}
