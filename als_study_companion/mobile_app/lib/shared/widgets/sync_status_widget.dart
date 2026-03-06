import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Sync status indicator widget.
class SyncStatusWidget extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 16, color: _color),
        const SizedBox(width: 4),
        Text(status.displayName, style: TextStyle(fontSize: 12, color: _color)),
      ],
    );
  }

  IconData get _icon {
    switch (status) {
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.pendingUpload:
        return Icons.cloud_upload_outlined;
      case SyncStatus.pendingDownload:
        return Icons.cloud_download_outlined;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.error:
        return Icons.cloud_off;
    }
  }

  Color get _color {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.pendingUpload:
      case SyncStatus.pendingDownload:
        return Colors.orange;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.error:
        return Colors.red;
    }
  }
}
