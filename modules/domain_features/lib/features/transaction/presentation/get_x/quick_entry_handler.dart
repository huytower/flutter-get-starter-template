import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:injectable/injectable.dart';

import 'quick_entry_batch_committer.dart';
import 'quick_entry_parser.dart';

/// The services behind quick entry, grouped by concern. A form controller that
/// mixes in [QuickEntryMixin] takes this through its constructor and exposes it
/// as `quickEntryHandler`.
///
/// Interim shape (phase A): the mixin still owns the reactive UI state; phase B
/// moves that state into a session object owned by the controller.
@injectable
class QuickEntryHandler {
  QuickEntryHandler(this.parser, this.speech, this.committer);

  final QuickEntryParser parser;
  final CcSpeechRecognizer speech;
  final QuickEntryBatchCommitter committer;
}
