import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({
    Key? key,
    this.message,
    this.onRetry,
    this.title,
    this.retryText,
  }) : super(key: key);

  final String? message;
  final VoidCallback? onRetry;
  final String? title;
  final String? retryText;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: CcBackBtn(
        onTap: () => Navigator.of(context).pop(),
        icon: Icons.arrow_back,
      ),
      title: CcText(title ?? 'Error'),
    ),
    body: CcColCenter(
      children: [
        Icon(
          Icons.error_outline,
          size: context.respIconSize(baseSize: 80.0),
          color: context.ccColorScheme.error,
        ),
        const CcSpaceLG(),
        CcText(
          message ?? 'An error occurred',
          textStyle: context.ccTextTheme.bodyLarge?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const CcSpaceLG(),
        if (onRetry != null)
          CcInteractBtnWrapper(
            onTap: onRetry!,
            useDebounce: true,
            isBouncing: true,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.respPadding(24.0),
                vertical: context.respPadding(12.0),
              ),
              decoration: BoxDecoration(
                color: context.ccColorScheme.primary,
                borderRadius: CcWidgetHelper.getBorderRoundedSM(),
              ),
              child: CcText(
                retryText ?? 'Retry',
                textStyle: context.textTheme.labelLarge?.copyWith(
                  color: context.ccColorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
