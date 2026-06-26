import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:equatable/equatable.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebState extends Equatable {
  final WebViewController? controller;
  final CcLayoutStatus status;
  final String? errorMessage;
  final String url;

  const WebState({
    this.controller,
    this.status = CcLayoutStatus.loading,
    this.errorMessage,
    this.url = 'https://flutter.dev',
  });

  factory WebState.init() => const WebState();

  WebState copyWith({
    WebViewController? controller,
    CcLayoutStatus? status,
    String? errorMessage,
    String? url,
  }) {
    return WebState(
      controller: controller ?? this.controller,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [controller, status, errorMessage, url];
}
