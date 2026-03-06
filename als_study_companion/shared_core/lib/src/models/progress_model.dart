import '../enums/sync_status.dart';

/// Student progress model tracking learning advancement.
class ProgressModel {
  final String id;
  final String studentId;
  final String lessonId;
  final String? quizId;
  final double progressPercent;
  final int? quizScore;
  final int timeSpentMinutes;
  final SyncStatus syncStatus;
  final DateTime lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProgressModel({
    required this.id,
    required this.studentId,
    required this.lessonId,
    this.quizId,
    this.progressPercent = 0.0,
    this.quizScore,
    this.timeSpentMinutes = 0,
    this.syncStatus = SyncStatus.synced,
    required this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'lesson_id': lessonId,
      'quiz_id': quizId,
      'progress_percent': progressPercent,
      'quiz_score': quizScore,
      'time_spent_minutes': timeSpentMinutes,
      'sync_status': syncStatus.name,
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      id: map['id'] as String,
      studentId: (map['student_id'] ?? map['studentId']) as String,
      lessonId: (map['lesson_id'] ?? map['lessonId']) as String,
      quizId: (map['quiz_id'] ?? map['quizId']) as String?,
      progressPercent:
          ((map['progress_percent'] ?? map['progressPercent']) as num?)
              ?.toDouble() ??
          0.0,
      quizScore: (map['quiz_score'] ?? map['quizScore']) as int?,
      timeSpentMinutes:
          (map['time_spent_minutes'] ?? map['timeSpentMinutes']) as int? ?? 0,
      syncStatus: SyncStatus.fromString(
        (map['sync_status'] ?? map['syncStatus']) as String? ?? 'synced',
      ),
      lastAccessedAt: DateTime.parse(
        (map['last_accessed_at'] ?? map['lastAccessedAt']) as String,
      ),
      createdAt: DateTime.parse(
        (map['created_at'] ?? map['createdAt']) as String,
      ),
      updatedAt: DateTime.parse(
        (map['updated_at'] ?? map['updatedAt']) as String,
      ),
    );
  }

  ProgressModel copyWith({
    String? id,
    String? studentId,
    String? lessonId,
    String? quizId,
    double? progressPercent,
    int? quizScore,
    int? timeSpentMinutes,
    SyncStatus? syncStatus,
    DateTime? lastAccessedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      lessonId: lessonId ?? this.lessonId,
      quizId: quizId ?? this.quizId,
      progressPercent: progressPercent ?? this.progressPercent,
      quizScore: quizScore ?? this.quizScore,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      syncStatus: syncStatus ?? this.syncStatus,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
