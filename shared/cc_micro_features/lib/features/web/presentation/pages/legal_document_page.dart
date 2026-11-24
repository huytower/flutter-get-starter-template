import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-screen page showing a bundled HTML legal document (Terms of Service,
/// Privacy Policy, ...) under a gradient app bar.
///
/// A document may hold several languages and switch between them with a
/// JavaScript function. Once the page has loaded, the script mapped to the
/// app's language code in [languageScripts] runs, or [defaultScript] when the
/// language has none. Leave both empty for a single-language document.
///
/// ```dart
/// LegalDocumentPage(
///   assetPath: 'assets/legal/privacy_policy.html',
///   title: tr('privacy_policy'),
///   languageScripts: const {'vi': 'showVietnamese()'},
///   defaultScript: 'showEnglish()',
/// )
/// ```
class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({
    super.key,
    required this.assetPath,
    required this.title,
    this.languageScripts = const {},
    this.defaultScript,
  });

  /// Flutter asset path of the HTML file.
  final String assetPath;

  /// Already-translated app bar title.
  final String title;

  /// Language code -> JavaScript to run after loading.
  final Map<String, String> languageScripts;

  /// JavaScript to run when [languageScripts] has no entry for the language.
  final String? defaultScript;

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
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
          onPageStarted: (_) {
            if (mounted) setState(() => _hasLoading = true);
          },
          onPageFinished: (_) => _onPageFinished(),
        ),
      )
      ..loadFlutterAsset(widget.assetPath);
  }

  void _onPageFinished() {
    if (!mounted) return;
    setState(() => _hasLoading = false);
    final languageCode = Localizations.localeOf(context).languageCode;
    final script = widget.languageScripts[languageCode] ?? widget.defaultScript;
    'Loaded ${widget.assetPath} for language $languageCode'.Log(
      'LegalDocumentPage',
    );
    if (script != null) _controller.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: buildDomainGradientAppBar(
        context,
        leading: CcIconButton.bouncing(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: scheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: CcText(
            widget.title,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onPrimary,
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
