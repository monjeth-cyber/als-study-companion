import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../repositories/download_repository.dart';

/// ViewModel for managing lesson downloads for offline access.
class DownloadViewModel extends ChangeNotifier {
  final DownloadRepository _repository = DownloadRepository();

  List<DownloadModel> _downloads = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DownloadModel> get downloads => _downloads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  /// Start downloading a lesson for offline access.
  Future<void> startDownload({
    required String lessonId,
    required String studentId,
  }) async {
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

      // TODO: Implement actual file download from Firebase Storage
      // 1. Get download URL from Firestore lesson record
      // 2. Download file to local storage
      // 3. Update download record with localFilePath and status

      await loadDownloads(studentId);
    } catch (e) {
      _errorMessage = 'Download failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Remove a downloaded lesson.
  Future<void> removeDownload(String downloadId, String studentId) async {
    try {
      // TODO: Also delete the local file
      await _repository.deleteDownload(downloadId);
      await loadDownloads(studentId);
    } catch (e) {
      _errorMessage = 'Failed to remove download: ${e.toString()}';
      notifyListeners();
    }
  }
}
