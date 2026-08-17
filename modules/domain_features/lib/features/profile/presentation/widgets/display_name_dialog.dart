import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class DisplayNameDialog extends StatefulWidget {
  const DisplayNameDialog({super.key, required this.currentName});

  final String currentName;

  static Future<String?> show(
    BuildContext context, {
    required String currentName,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DisplayNameDialog(currentName: currentName),
    );
  }

  @override
  State<DisplayNameDialog> createState() => _DisplayNameDialogState();
}

class _DisplayNameDialogState extends State<DisplayNameDialog> {
  late final TextEditingController _nameController;

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    Navigator.pop(context, _nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: context.respPadding(CcPaddingParams.SPACE_LG),
        right: context.respPadding(CcPaddingParams.SPACE_LG),
        top: context.respPadding(CcPaddingParams.SPACE_LG),
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            context.respPadding(CcPaddingParams.SPACE_LG),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            el.tr(CcLocaleKeys.profile_display_name_title),
            textStyle: context.ccTextTheme.headlineSmall?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: context.ccColorScheme.primary,
            ),
          ),
          const CcSpaceSM(),
          TextField(
            controller: _nameController,
            maxLength: 20,
            autofocus: true,
            decoration: InputDecoration(
              hintText: el.tr(CcLocaleKeys.profile_display_name_hint),
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: context.ccColorScheme.onSurfaceVariant,
                        size: context.respIconSize(baseSize: 20),
                      ),
                      onPressed: () => _nameController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const CcSpaceMD(),
          CcSaveButton(
            onPressed: _isValid ? _onSave : null,
            label: el.tr(CcLocaleKeys.profile_display_name_save),
          ),
        ],
      ),
    );
  }
}
