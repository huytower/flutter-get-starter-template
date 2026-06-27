import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/cc_message_entity.dart';

/// Abstract service for handling push notifications and messaging.
/// Designed to be state-management agnostic and swappable (e.g., Firebase, OneSignal).
abstract class CcMessagingService {
  /// Request notification permissions from the user.
  Future<void> requestPermission();

  /// Get the unique device token for messaging.
  Future<Result<String?, CcFailure>> getToken();

  /// Stream of new tokens when the token is refreshed.
  Stream<String> get onTokenRefresh;

  /// Stream of incoming messages while the app is in the foreground.
  Stream<CcMessageEntity> get onMessage;

  /// Stream of messages that caused the app to open from a terminated or background state.
  Stream<CcMessageEntity> get onMessageOpenedApp;
}
