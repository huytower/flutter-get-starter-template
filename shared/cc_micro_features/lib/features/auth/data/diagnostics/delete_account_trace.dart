import 'package:catcher_2/catcher_2.dart';

/// Steps of one account deletion, sent to Slack as a single report when the
/// deletion ends, so release builds show the whole flow.
///
/// The Slack alert shows only the first line of an error and drops identical
/// first lines within 5 minutes, so the report is one line that starts with
/// a per-attempt run id.
class DeleteAccountTrace {
  DeleteAccountTrace() : _startedAt = DateTime.now();

  final DateTime _startedAt;
  final List<String> _steps = [];

  void add(String step) {
    final ms = DateTime.now().difference(_startedAt).inMilliseconds;
    // Error texts can span lines; Slack would only show the first one.
    _steps.add('+${ms}ms ${step.replaceAll(RegExp(r'\s*\n\s*'), ' ')}');
  }

  void send(String outcome) {
    final run = _startedAt.millisecondsSinceEpoch.toRadixString(36);
    Catcher2.reportCheckedError(
      Exception('[DeleteAccount] run=$run | $outcome | ${_steps.join(' ▸ ')}'),
      StackTrace.current,
    );
  }
}
