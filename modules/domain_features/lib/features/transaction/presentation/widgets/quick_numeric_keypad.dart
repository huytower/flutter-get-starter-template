import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class QuickNumericKeypad extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final Color activeColor;

  const QuickNumericKeypad({
    super.key,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClear,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: context.ccColorScheme.outlineVariant.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(context, ['1', '2', '3']),
          _buildRow(context, ['4', '5', '6']),
          _buildRow(context, ['7', '8', '9']),
          _buildRow(context, ['000', '0', 'DEL']),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Row(
      children: keys
          .map((key) => Expanded(child: _buildKey(context, key)))
          .toList(),
    );
  }

  Widget _buildKey(BuildContext context, String label) {
    final bool isDelete = label == 'DEL';

    return CcInteractBtnWrapper(
      useDebounce: false,
      isBouncing: true,
      onTap: () => isDelete ? onDelete() : onKeyPress(label),
      child: Container(
        height: context.respDim(30),
        margin: EdgeInsets.all(context.respDim(2)),
        decoration: BoxDecoration(
          color: context.ccColorScheme.surface,
          borderRadius: BorderRadius.circular(context.respDim(12)),
          boxShadow: [
            BoxShadow(
              color: context.ccColorScheme.onSurface.withOpacity(0.02),
              blurRadius: context.respDim(2),
              offset: Offset(0, context.respDim(1)),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isDelete
            ? Icon(
                Icons.backspace_outlined,
                color: context.ccColorScheme.onSurfaceVariant,
                size: context.respIconSize(baseSize: 18),
              )
            : CcText(
                label,
                align: Alignment.center,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.titleMedium?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  fontSize: context.respFontSize(16),
                  color: label == '000'
                      ? activeColor
                      : context.ccColorScheme.onSurface,
                ),
              ),
      ),
    );
  }
}
