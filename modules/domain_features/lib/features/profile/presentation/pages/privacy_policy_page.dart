import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../widgets/legal_document_view.dart';

/// The app's Privacy Policy (App Store guideline 5.1.1(i)): what data is
/// collected, how and why, which third parties receive it, retention and
/// deletion, and how to withdraw consent.
@RoutePage()
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentView(
      assetPath: 'assets/legal/privacy_policy.html',
      title: el.tr(PrjLocaleKeys.profile_privacy_policy),
    );
  }
}
