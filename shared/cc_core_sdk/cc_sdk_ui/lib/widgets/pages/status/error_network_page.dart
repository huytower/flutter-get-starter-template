import 'package:cc_sdk_ui/core/extensions/cc_context_extension.dart';
import 'package:flutter/material.dart';

// Purpose:
// small reusable widgets for loading states and empty API responses
// intended as part of the shared UI library
class ErrorNetworkPage extends StatelessWidget {
  const ErrorNetworkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(color: context.ccColorScheme.error));
  }
}
