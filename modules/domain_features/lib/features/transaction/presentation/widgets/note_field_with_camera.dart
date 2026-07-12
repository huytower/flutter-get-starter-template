import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

/// Reusable note input field with camera icon for image attachment.
/// State-management agnostic widget - can be used with any state management approach.
class NoteFieldWithCamera extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onCameraTap;
  final VoidCallback? onTap;
  final String? hintText;

  const NoteFieldWithCamera({
    super.key,
    required this.controller,
    this.onCameraTap,
    this.onTap,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onTap: onTap,
              style: context.ccTextTheme.bodyMedium?.copyWith(
                fontSize: context.respFontSize(14),
              ),
              decoration: InputDecoration(
                hintText: hintText ?? el.tr(CcLocaleKeys.transaction_note_hint),
                hintStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                  fontSize: context.respFontSize(13),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCameraTap,
            child: Icon(
              Icons.camera_alt_outlined,
              size: 20,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
