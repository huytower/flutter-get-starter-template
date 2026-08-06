import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class TransactionSubmitButton extends StatelessWidget {
  final String text;
  final bool isSubmitting;
  final bool isEnabled;
  final VoidCallback onTap;
  final Color activeColor;
  final Widget? badge;

  const TransactionSubmitButton({
    super.key,
    required this.text,
    required this.isSubmitting,
    required this.isEnabled,
    required this.onTap,
    required this.activeColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: double.infinity,
              height: context.respDim(40),
              child: ElevatedButton(
                onPressed: isEnabled && !isSubmitting ? onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? SizedBox(
                        width: context.respDim(20),
                        height: context.respDim(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            scheme.onPrimary,
                          ),
                        ),
                      )
                    : CcText(
                        text,
                        align: Alignment.center,
                        textAlign: TextAlign.center,
                        textStyle: context.ccTextTheme.titleMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (badge != null) Positioned(top: -6, right: -6, child: badge!),
          ],
        ),
      ),
    );
  }
}
