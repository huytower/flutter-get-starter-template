import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:injectable/injectable.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'web_state.dart';

@lazySingleton
class WebCubit extends Cubit<WebState> {
  WebCubit() : super(WebState.init());

  void initController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar if needed.
          },
          onPageStarted: (String url) {
            emit(state.copyWith(status: CcLayoutStatus.loading, url: url));
          },
          onPageFinished: (String url) {
            emit(state.copyWith(status: CcLayoutStatus.success, url: url));
          },
          onWebResourceError: (WebResourceError error) {
            emit(
              state.copyWith(
                status: CcLayoutStatus.error,
                errorMessage: error.description,
              ),
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(state.url));

    emit(state.copyWith(controller: controller));
  }
}
