import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-screen page that shows a bundled bilingual legal HTML document (Terms
/// of Service, Privacy Policy) in the app's language.
///
/// The HTML holds both languages and exposes `showEnglish()` /
/// `showVietnamese()`; the matching one is called once the page has loaded.
class LegalDocumentView extends StatefulWidget {
  const LegalDocumentView({
    super.key,
    required this.assetPath,
    required this.title,
  });

  /// Flutter asset path of the HTML file, e.g. `assets/legal/privacy_policy.html`.
  final String assetPath;

  /// Already-translated title for the app bar.
  final String title;

  @override
  State<LegalDocumentView> createState() => _LegalDocumentViewState();
}

class _LegalDocumentViewState extends State<LegalDocumentView> {
  late final WebViewController _controller;
  bool _hasLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _hasLoading = true),
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _hasLoading = false);
            final languageCode = el.EasyLocalization.of(
              context,
            )?.locale.languageCode;
            'Loading ${widget.assetPath} with language: $languageCode'.Log(
              'LegalDocumentView',
            );
            _controller.runJavaScript(
              languageCode == 'vi' ? 'showVietnamese()' : 'showEnglish()',
            );
          },
        ),
      )
      ..loadFlutterAsset(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ccColorScheme.surface,
      appBar: buildDomainGradientAppBar(
        context,
        leading: CcIconButton.bouncing(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: CcText(
            widget.title,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: context.ccColorScheme.onPrimary,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_hasLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
