import 'package:auto_route/annotations.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/di/di.dart';
import '../cubit/web_cubit.dart';

@RoutePage()
class WebPage extends StatelessWidget {
  const WebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WebCubit>()..initController(),
      child: const WebView(),
    );
  }
}

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> with CcViewConfigMixin {
  @override
  CcLayoutStatus get layoutStatus => context.watch<WebCubit>().state.status;

  @override
  String get errorMessage =>
      context.watch<WebCubit>().state.errorMessage ?? 'Unknown Error';

  @override
  Widget? buildContent() {
    final controller = context.read<WebCubit>().state.controller;
    if (controller == null) return const SizedBox.shrink();

    return WebViewWidget(controller: controller);
  }
}
