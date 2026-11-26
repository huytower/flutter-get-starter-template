import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../helper/name_suggestions.dart';

/// Name field of the "add" sheets (wallet, investment, liability) with
/// tap-to-fill name suggestions underneath, styled like the quick amounts.
///
/// Suggestions longer than [maxLength] are left out, since the field could
/// not hold them.
class PrjSuggestedNameField extends StatelessWidget {
  const PrjSuggestedNameField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.maxLength,
    this.suggestions = const [],
    this.errorText,
    this.onClear,
  });

  final TextEditingController controller;
  final String labelText;
  final int maxLength;
  final List<CcQuickValue<String>> suggestions;
  final String? errorText;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final fitting = [
      for (final suggestion in suggestions)
        if (suggestion.value.length <= maxLength) suggestion,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcNameInputField(
          controller: controller,
          labelText: labelText,
          hintText: el.tr(PrjLocaleKeys.common_name_suggestion_hint),
          errorText: errorText,
          maxLength: maxLength,
          maxLengthWarningText: el.tr(
            PrjLocaleKeys.validation_max_length_reached,
            namedArgs: {'count': '$maxLength'},
          ),
          onClear: onClear,
        ),
        if (fitting.isNotEmpty) ...[
          const CcSpaceSM(),
          CcQuickValueChips<String>(
            items: fitting,
            onSelected: (name) => NameSuggestions.apply(controller, name),
            activeColor: context.ccColorScheme.primary,
          ),
        ],
      ],
    );
  }
}
