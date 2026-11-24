import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../widgets/legal_document_view.dart';

@RoutePage()
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentView(
      assetPath: 'assets/legal/terms_of_service.html',
      title: el.tr(PrjLocaleKeys.profile_terms),
    );
  }
}
