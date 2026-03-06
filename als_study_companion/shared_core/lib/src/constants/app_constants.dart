/// Application-wide constants for ALS Study Companion.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ALS Study Companion';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Quiz
  static const int defaultQuizTimeMinutes = 30;
  static const int defaultPassingScore = 75;

  // Session
  static const int defaultSessionDurationMinutes = 60;

  // Sync
  static const int syncIntervalMinutes = 15;
  static const int maxRetryAttempts = 3;

  // Download
  static const int maxConcurrentDownloads = 3;

  // File Size Limits (in bytes)
  static const int maxVideoSizeBytes = 500 * 1024 * 1024; // 500MB
  static const int maxDocumentSizeBytes = 50 * 1024 * 1024; // 50MB
  static const int maxProfileImageSizeBytes = 5 * 1024 * 1024; // 5MB
}
