import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class GuidelineSuccessDialog extends StatefulWidget {
  const GuidelineSuccessDialog({super.key});

  @override
  State<GuidelineSuccessDialog> createState() => _GuidelineSuccessDialogState();
}

class _GuidelineSuccessDialogState extends State<GuidelineSuccessDialog> {
  Timer? _timer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width * 0.9,
            maxHeight: size.height * 0.2,
          ),
          child: CcRewardCompletionBanner(
            message: el.tr(CcLocaleKeys.guideline_success_dialog_message),
            onClose: _dismiss,
          ),
        ),
      ),
    );
  }
}
