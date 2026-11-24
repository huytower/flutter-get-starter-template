import 'package:auto_route/annotations.dart';
import 'package:cc_micro_features/export_micro_features.dart'
    show LegalDocumentPage;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../helper/legal_document_scripts.dart';

@RoutePage()
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentPage(
      assetPath: 'assets/legal/terms_of_service.html',
      title: el.tr(PrjLocaleKeys.profile_terms),
      languageScripts: LegalDocumentScripts.byLanguage,
      defaultScript: LegalDocumentScripts.fallback,
    );
  }
}
