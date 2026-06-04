import 'package:flutter/material.dart';

import '../../../../core/extensions/cc_context_extension.dart';

// Purpose:
// small reusable widgets for loading states and empty API responses
// intended as part of the shared UI library
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(color: context.ccColorScheme.error));
  }
}
