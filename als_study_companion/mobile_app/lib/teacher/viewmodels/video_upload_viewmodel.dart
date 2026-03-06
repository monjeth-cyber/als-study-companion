import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:backend_services/backend_services.dart';

/// ViewModel for teacher video uploads with progress tracking.
class VideoUploadViewModel extends ChangeNotifier {
  final SupabaseStorageService _storageService = SupabaseStorageService();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadedUrl;
  String? _errorMessage;

  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get uploadedUrl => _uploadedUrl;
  String? get errorMessage => _errorMessage;

  /// Upload a lesson video with progress reporting.
  Future<String?> uploadLessonVideo({
    required String lessonId,
    required Uint8List videoBytes,
    required String fileName,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _uploadedUrl = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = await _storageService.uploadLessonVideo(
        lessonId: lessonId,
        videoBytes: videoBytes,
        fileName: fileName,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );
      _uploadedUrl = url;
      _isUploading = false;
      notifyListeners();
      return url;
    } catch (e) {
      _errorMessage = 'Upload failed: ${e.toString()}';
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  /// Upload a lesson material (PDF, document, etc.).
  Future<String?> uploadLessonMaterial({
    required String lessonId,
    required Uint8List fileBytes,
    required String fileName,
    String contentType = 'application/pdf',
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = await _storageService.uploadLessonMaterial(
        lessonId: lessonId,
        fileBytes: fileBytes,
        fileName: fileName,
        contentType: contentType,
      );
      _uploadProgress = 1.0;
      _uploadedUrl = url;
      _isUploading = false;
      notifyListeners();
      return url;
    } catch (e) {
      _errorMessage = 'Upload failed: ${e.toString()}';
      _isUploading = false;
      notifyListeners();
      return null;
    }
  }

  void reset() {
    _isUploading = false;
    _uploadProgress = 0.0;
    _uploadedUrl = null;
    _errorMessage = null;
    notifyListeners();
  }
}
