import '../enum/sync_status.dart';

/// Metadata for tracking synchronization state of entities.
class SyncMetadata {
  final String localId;
  final String? remoteId;
  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final DateTime? lastModifiedAt;
  final String? errorMessage;

  const SyncMetadata({
    required this.localId,
    this.remoteId,
    required this.status,
    this.lastSyncedAt,
    this.lastModifiedAt,
    this.errorMessage,
  });

  /// Creates a copy with updated fields.
  SyncMetadata copyWith({
    String? localId,
    String? remoteId,
    SyncStatus? status,
    DateTime? lastSyncedAt,
    DateTime? lastModifiedAt,
    String? errorMessage,
  }) {
    return SyncMetadata(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Creates a pending sync metadata for a new local entity.
  factory SyncMetadata.pending(String localId) {
    return SyncMetadata(
      localId: localId,
      status: SyncStatus.pending,
      lastModifiedAt: DateTime.now(),
    );
  }

  /// Creates a synced metadata.
  factory SyncMetadata.synced({
    required String localId,
    required String remoteId,
    DateTime? lastSyncedAt,
  }) {
    return SyncMetadata(
      localId: localId,
      remoteId: remoteId,
      status: SyncStatus.synced,
      lastSyncedAt: lastSyncedAt ?? DateTime.now(),
      lastModifiedAt: DateTime.now(),
    );
  }

  /// Creates a failed sync metadata.
  factory SyncMetadata.failed({
    required String localId,
    required String errorMessage,
  }) {
    return SyncMetadata(
      localId: localId,
      status: SyncStatus.failed,
      errorMessage: errorMessage,
      lastModifiedAt: DateTime.now(),
    );
  }

  /// Marks a previously synced or pending entity as having a new local change.
  SyncMetadata withLocalChange(String localId) {
    return copyWith(
      localId: localId,
      status: SyncStatus.pending,
      lastModifiedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'remoteId': remoteId,
      'status': status.name,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  factory SyncMetadata.fromJson(Map<String, dynamic> json) {
    return SyncMetadata(
      localId: json['localId'] as String,
      remoteId: json['remoteId'] as String?,
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      lastModifiedAt: json['lastModifiedAt'] != null
          ? DateTime.parse(json['lastModifiedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
