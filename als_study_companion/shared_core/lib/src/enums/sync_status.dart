/// Synchronization status for offline-first data flow.
enum SyncStatus {
  synced,
  pendingUpload,
  pendingDownload,
  syncing,
  error;

  String get displayName {
    switch (this) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pendingUpload:
        return 'Pending Upload';
      case SyncStatus.pendingDownload:
        return 'Pending Download';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.error:
        return 'Sync Error';
    }
  }

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => SyncStatus.pendingUpload,
    );
  }
}
