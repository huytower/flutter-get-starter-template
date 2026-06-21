import 'package:cc_sdk/domain/entities/cc_message_entity.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:cc_sdk/domain/services/cc_messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

@LazySingleton(as: CcMessagingService)
class FirebaseMessagingServiceImpl implements CcMessagingService {
  final FirebaseMessaging _firebaseMessaging;

  FirebaseMessagingServiceImpl(this._firebaseMessaging);

  @override
  Future<void> requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Future<Result<String?, CcFailure>> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return Success(token);
    } catch (e) {
      return const Error(UnknownFailure(CcLocaleKeys.app_error_general));
    }
  }

  @override
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  @override
  Stream<CcMessageEntity> get onMessage =>
      FirebaseMessaging.onMessage.map(_mapToEntity);

  @override
  Stream<CcMessageEntity> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_mapToEntity);

  CcMessageEntity _mapToEntity(RemoteMessage message) {
    return CcMessageEntity(
      messageId: message.messageId,
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }
}
