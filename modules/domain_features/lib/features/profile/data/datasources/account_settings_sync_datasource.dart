import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:domain_features/core/data/sync/firestore_sync_service.dart';
import 'package:domain_features/core/data/sync/generic_sync_datasource.dart';
import 'package:injectable/injectable.dart';

/// The signed-in account's settings document,
/// `users/{uid}/profile/settings` in Firestore.
@injectable
class AccountSettingsSyncDataSource {
  AccountSettingsSyncDataSource(
    FirestoreSyncService syncService,
    SessionContract session,
  ) : _delegate = GenericSyncDataSource(syncService, session, collectionName);

  /// Firestore collection under `users/{uid}/`; also wiped on account deletion.
  static const String collectionName = 'profile';
  static const String _documentId = 'settings';

  final GenericSyncDataSource _delegate;

  /// The stored settings, or null when this account has none in the cloud yet.
  Future<Map<String, dynamic>?> fetch() async {
    final documents = await _delegate.fetch();
    for (final document in documents) {
      if (document['remoteId'] == _documentId) return document;
    }
    return null;
  }

  /// Replaces the stored settings with [data].
  Future<void> push(Map<String, Object?> data) =>
      _delegate.sync(localId: _documentId, data: data, remoteId: _documentId);
}
