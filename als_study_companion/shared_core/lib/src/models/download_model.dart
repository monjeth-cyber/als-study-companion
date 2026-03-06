import '../enums/download_status.dart';

/// Download model for tracking offline content downloads.
class DownloadModel {
  final String id;
  final String lessonId;
  final String studentId;
  final String? localFilePath;
  final double downloadProgress;
  final DownloadStatus status;
  final int fileSizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DownloadModel({
    required this.id,
    required this.lessonId,
    required this.studentId,
    this.localFilePath,
    this.downloadProgress = 0.0,
    this.status = DownloadStatus.notDownloaded,
    this.fileSizeBytes = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'student_id': studentId,
      'local_file_path': localFilePath,
      'download_progress': downloadProgress,
      'status': status.name,
      'file_size_bytes': fileSizeBytes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DownloadModel.fromMap(Map<String, dynamic> map) {
    return DownloadModel(
      id: map['id'] as String,
      lessonId: (map['lesson_id'] ?? map['lessonId']) as String,
      studentId: (map['student_id'] ?? map['studentId']) as String,
      localFilePath:
          (map['local_file_path'] ?? map['localFilePath']) as String?,
      downloadProgress:
          ((map['download_progress'] ?? map['downloadProgress']) as num?)
              ?.toDouble() ??
          0.0,
      status: DownloadStatus.fromString(
        (map['status'] as String?) ?? 'notDownloaded',
      ),
      fileSizeBytes:
          (map['file_size_bytes'] ?? map['fileSizeBytes']) as int? ?? 0,
      createdAt: DateTime.parse(
        (map['created_at'] ?? map['createdAt']) as String,
      ),
      updatedAt: DateTime.parse(
        (map['updated_at'] ?? map['updatedAt']) as String,
      ),
    );
  }

  DownloadModel copyWith({
    String? id,
    String? lessonId,
    String? studentId,
    String? localFilePath,
    double? downloadProgress,
    DownloadStatus? status,
    int? fileSizeBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DownloadModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      studentId: studentId ?? this.studentId,
      localFilePath: localFilePath ?? this.localFilePath,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      status: status ?? this.status,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
