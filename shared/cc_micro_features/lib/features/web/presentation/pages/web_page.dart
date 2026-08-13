import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/di/di.dart';
import '../cubit/web_cubit.dart';

@RoutePage()
class WebPage extends StatelessWidget {
  const WebPage({super.key, this.url, this.title});

  final String? url;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WebCubit>()..initController(url: url),
      child: WebViewPage(title: title),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, this.title});

  final String? title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ccColorScheme.surface,
      appBar: AppBar(
        title: CcText(
          widget.title ?? el.tr(CcLocaleKeys.profile_terms),
          textStyle: context.ccTextTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: context.ccColorScheme.surface,
        elevation: 0,
        leading: CcBackBtn(onTap: () => Navigator.of(context).pop()),
      ),
      body: Stack(
        children: [
          _buildWebView(context),
          _buildLoadingIndicator(context),
        ],
      ),
    );
  }

  Widget _buildWebView(BuildContext context) {
    final state = context.watch<WebCubit>().state;

    if (state.status == CcLayoutStatus.error) {
      return Center(
        child: CcText(
          state.errorMessage ?? 'Unknown Error',
          textStyle: context.ccTextTheme.bodyMedium,
        ),
      );
    }

    final controller = state.controller;
    if (controller == null) return const SizedBox.shrink();

    return WebViewWidget(controller: controller);
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final status = context.watch<WebCubit>().state.status;
    if (status == CcLayoutStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  }
}
