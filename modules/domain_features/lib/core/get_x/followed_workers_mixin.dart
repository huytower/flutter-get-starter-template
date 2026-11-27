import 'package:get/get.dart';

/// Follows notifiers that outlive the controller (app-wide ones, or another
/// screen's) and stops when it closes: GetX does not cancel a worker with its
/// controller, so a closed one would keep reacting.
///
/// ```dart
/// follow(CurrencyConstants.onCurrencyChanged, (_) => reload());
/// ```
mixin FollowedWorkersMixin on GetxController {
  final List<Worker> _followed = [];

  /// Calls [onChange] on every change of [source] until this closes.
  void follow<T>(RxInterface<T> source, void Function(T value) onChange) =>
      _followed.add(ever<T>(source, onChange));

  @override
  void onClose() {
    for (final worker in _followed) {
      worker.dispose();
    }
    _followed.clear();
    super.onClose();
  }
}
