import 'package:auto_route/annotations.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            // Sync language with app locale
            final locale = el.EasyLocalization.of(context)?.locale;
            'Loading Terms of Service with language: ${locale?.languageCode}'
                .Log('TermsOfServicePage');
            if (locale?.languageCode == 'en') {
              _controller.runJavaScript('showEnglish()');
            } else {
              _controller.runJavaScript('showVietnamese()');
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/legal/terms_of_service.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ccColorScheme.surface,
      appBar: AppBar(
        title: CcText(
          el.tr(CcLocaleKeys.profile_terms),
          textStyle: context.ccTextTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: context.ccColorScheme.surface,
        elevation: 0,
        leading: CcBackBtn(onTap: () => Navigator.of(context).pop()),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
