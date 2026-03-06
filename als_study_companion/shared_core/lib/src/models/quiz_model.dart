import '../enums/sync_status.dart';

/// Quiz model representing an assessment for a lesson.
class QuizModel {
  final String id;
  final String lessonId;
  final String title;
  final String description;
  final int timeLimitMinutes;
  final int passingScore;
  final int totalQuestions;
  final String teacherId;
  final SyncStatus syncStatus;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuizModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    this.timeLimitMinutes = 30,
    this.passingScore = 75,
    this.totalQuestions = 0,
    required this.teacherId,
    this.syncStatus = SyncStatus.synced,
    this.isPublished = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'title': title,
      'description': description,
      'time_limit_minutes': timeLimitMinutes,
      'passing_score': passingScore,
      'total_questions': totalQuestions,
      'teacher_id': teacherId,
      'sync_status': syncStatus.name,
      'is_published': isPublished ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] as String,
      lessonId: (map['lesson_id'] ?? map['lessonId']) as String,
      title: map['title'] as String,
      description: map['description'] as String,
      timeLimitMinutes:
          (map['time_limit_minutes'] ?? map['timeLimitMinutes']) as int? ?? 30,
      passingScore: (map['passing_score'] ?? map['passingScore']) as int? ?? 75,
      totalQuestions:
          (map['total_questions'] ?? map['totalQuestions']) as int? ?? 0,
      teacherId: (map['teacher_id'] ?? map['teacherId']) as String,
      syncStatus: SyncStatus.fromString(
        (map['sync_status'] ?? map['syncStatus']) as String? ?? 'synced',
      ),
      isPublished:
          (map['is_published'] ?? map['isPublished']) == 1 ||
          (map['is_published'] ?? map['isPublished']) == true,
      createdAt: DateTime.parse(
        (map['created_at'] ?? map['createdAt']) as String,
      ),
      updatedAt: DateTime.parse(
        (map['updated_at'] ?? map['updatedAt']) as String,
      ),
    );
  }

  QuizModel copyWith({
    String? id,
    String? lessonId,
    String? title,
    String? description,
    int? timeLimitMinutes,
    int? passingScore,
    int? totalQuestions,
    String? teacherId,
    SyncStatus? syncStatus,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      description: description ?? this.description,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      passingScore: passingScore ?? this.passingScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      teacherId: teacherId ?? this.teacherId,
      syncStatus: syncStatus ?? this.syncStatus,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
