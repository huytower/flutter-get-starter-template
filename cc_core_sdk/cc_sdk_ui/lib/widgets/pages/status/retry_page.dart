import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Retry page displayed when an action fails and can be retried.
/// Shows a retry button to attempt the action again.
class RetryPage extends StatelessWidget {
  const RetryPage({
    Key? key,
    this.message = 'Something went wrong',
    this.onRetry,
  }) : super(key: key);

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: context.respIconSize(baseSize: 64.0),
              color: context.ccColorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.ccTextTheme.bodyLarge?.copyWith(
                color: context.ccColorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(el.tr(CcLocaleKeys.app_error_retry)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
