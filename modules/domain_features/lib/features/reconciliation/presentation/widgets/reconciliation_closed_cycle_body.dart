import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'reconciliation_history_section.dart';

/// The reconciliation page once the current audit cycle is closed: only the
/// history, so nothing on it can start another reconciliation. The latest one
/// can be undone, which re-opens the cycle.
class ReconciliationClosedCycleBody extends StatelessWidget {
  const ReconciliationClosedCycleBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_SM)),
      children: const [
        CcMaxWidth.content(child: ReconciliationHistorySection(hasUndo: true)),
      ],
    );
  }
}
