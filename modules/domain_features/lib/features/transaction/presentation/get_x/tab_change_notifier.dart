import 'transaction_controller.dart';
import 'transaction_form_controller.dart';

/// Tells the forms behind two tabs that one was left and the other opened.
///
/// Each form decides for itself what to refresh in
/// [TransactionFormController.onTabActivated] /
/// [TransactionFormController.onTabDeactivated]; this is the one place that
/// says when. [controllerOf] returns a tab's form controller, or null when it
/// does not exist yet (nothing to notify).
///
/// ```dart
/// notifyTabChange(from: before, to: now, controllerOf: _builtFormControllerFor);
/// ```
void notifyTabChange({
  required TransactionTabKind? from,
  required TransactionTabKind? to,
  required TransactionFormController? Function(TransactionTabKind tab)
  controllerOf,
}) {
  if (from == to) return;
  if (from != null) controllerOf(from)?.onTabDeactivated();
  if (to != null) controllerOf(to)?.onTabActivated();
}
