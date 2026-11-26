import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/navigation/domain_router.gr.dart';
import '../../domain/usecases/get_reconciliation_availability_usecase.dart';
import '../get_x/reconciliation_controller.dart';
import '../widgets/reconciliation_locked_sheet.dart';

/// Opens the reconciliation page, unless the current audit cycle already has
/// a reconciliation: then the user sees when the next one opens and why,
/// and can still open the page to look at the history or undo.
@injectable
class ReconciliationEntryGuard {
  ReconciliationEntryGuard(this._getAvailability);

  final GetReconciliationAvailabilityUseCase _getAvailability;

  Future<void> open(BuildContext context) async {
    final availability = (await _getAvailability()).tryGetSuccess();
    if (!context.mounted) return;

    // On a read error the page opens as before; the reconciliation use case
    // still refuses a second one in the same cycle.
    if (availability != null && availability.hasReconciledThisCycle) {
      final hasChosenHistory = await ReconciliationLockedSheet.show(
        context,
        availability,
      );
      if (!hasChosenHistory || !context.mounted) return;
    }

    // The page controller is permanent and loads once; reload so the history
    // and the open/closed state match today, not the last visit.
    if (Get.isRegistered<ReconciliationController>()) {
      unawaited(Get.find<ReconciliationController>().loadHistory());
    }
    await context.router.push(const ReconcileRoute());
  }
}
