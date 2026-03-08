import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_core/shared_core.dart';
import 'package:backend_services/backend_services.dart';
import '../repositories/download_repository.dart';

/// ViewModel for managing lesson downloads for offline access.
class DownloadViewModel extends ChangeNotifier {
  final DownloadRepository _repository = DownloadRepository();
  final SupabaseStorageService _storageService = SupabaseStorageService();

  List<DownloadModel> _downloads = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, double> _progressMap = {};

  List<DownloadModel> get downloads => _downloads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get download progress for a specific lesson.
  double getProgress(String lessonId) => _progressMap[lessonId] ?? 0.0;

  /// Get total storage used by all downloads (in bytes).
  int get totalStorageUsed =>
      _downloads.fold(0, (sum, d) => sum + d.fileSizeBytes);

  /// Load all downloads for a student.
  Future<void> loadDownloads(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _downloads = await _repository.getDownloadsByStudent(studentId);
    } catch (e) {
      _errorMessage = 'Failed to load downloads: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Check available device storage.
  Future<int> getAvailableStorage() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final stat = await dir.stat();
      // FileStat doesn't expose free space; use a conservative default
      // In production, use platform channels for accurate free space.
      return stat.size > 0
          ? 500 * 1024 * 1024
          : 500 * 1024 * 1024; // Default 500MB
    } catch (_) {
      return 500 * 1024 * 1024;
    }
  }

  /// Start downloading a lesson video for offline access.
  Future<void> startDownload({
    required String lessonId,
    required String studentId,
    required String videoUrl,
  }) async {
    // Check if already downloading
    if (_progressMap.containsKey(lessonId) && _progressMap[lessonId]! > 0) {
      return;
    }

    try {
      final now = DateTime.now();
      final download = DownloadModel(
        id: '${studentId}_$lessonId',
        lessonId: lessonId,
        studentId: studentId,
        status: DownloadStatus.downloading,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.saveDownload(download);
      _progressMap[lessonId] = 0.0;
      notifyListeners();

      // Get signed URL for the video
      final signedUrl = await _storageService.getSignedUrl(
        SupabaseStorageService.videosBucket,
        videoUrl,
        expiresIn: 7200,
      );

      // Download file to local directory
      final dir = await getApplicationDocumentsDirectory();
      final localDir = Directory('${dir.path}/downloads/$lessonId');
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }
      final localPath = '${localDir.path}/video.mp4';
      final file = File(localPath);

      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(signedUrl));
      final response = await request.close();

      final totalBytes = response.contentLength;
      int receivedBytes = 0;
      final sink = file.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          _progressMap[lessonId] = receivedBytes / totalBytes;
          notifyListeners();
        }
      }
      await sink.close();
      httpClient.close();

      // Update download record
      final completed = download.copyWith(
        localFilePath: localPath,
        downloadProgress: 1.0,
        status: DownloadStatus.downloaded,
        fileSizeBytes: receivedBytes,
        updatedAt: DateTime.now(),
      );
      await _repository.updateDownload(completed);
      _progressMap.remove(lessonId);
      await loadDownloads(studentId);
    } catch (e) {
      _errorMessage = 'Download failed: ${e.toString()}';
      _progressMap.remove(lessonId);

      // Mark as failed
      try {
        final failed = DownloadModel(
          id: '${studentId}_$lessonId',
          lessonId: lessonId,
          studentId: studentId,
          status: DownloadStatus.failed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _repository.updateDownload(failed);
      } catch (_) {}

      notifyListeners();
    }
  }

  /// Remove a downloaded lesson and delete the local file.
  Future<void> removeDownload(String downloadId, String studentId) async {
    try {
      final download = _downloads.firstWhere(
        (d) => d.id == downloadId,
        orElse: () => throw Exception('Download not found'),
      );
      // Delete local file
      if (download.localFilePath != null) {
        final file = File(download.localFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _repository.deleteDownload(downloadId);
      await loadDownloads(studentId);
    } catch (e) {
      _errorMessage = 'Failed to remove download: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Retry a failed download.
  Future<void> retryDownload({
    required String lessonId,
    required String studentId,
    required String videoUrl,
  }) async {
    await removeDownload('${studentId}_$lessonId', studentId);
    await startDownload(
      lessonId: lessonId,
      studentId: studentId,
      videoUrl: videoUrl,
    );
  }
}
