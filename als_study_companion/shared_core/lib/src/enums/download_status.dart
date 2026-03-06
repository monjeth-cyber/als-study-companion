/// Status of a content download.
enum DownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
  failed;

  String get displayName {
    switch (this) {
      case DownloadStatus.notDownloaded:
        return 'Not Downloaded';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.downloaded:
        return 'Downloaded';
      case DownloadStatus.failed:
        return 'Failed';
    }
  }

  static DownloadStatus fromString(String value) {
    return DownloadStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => DownloadStatus.notDownloaded,
    );
  }
}
