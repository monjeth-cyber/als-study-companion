/// Session model for scheduled learning sessions.
class SessionModel {
  final String id;
  final String teacherId;
  final String title;
  final String? description;
  final String? lessonId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final List<String> studentIds;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionModel({
    required this.id,
    required this.teacherId,
    required this.title,
    this.description,
    this.lessonId,
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.studentIds = const [],
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'title': title,
      'description': description,
      'lesson_id': lessonId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'student_ids': studentIds.join(','),
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as String,
      teacherId: (map['teacher_id'] ?? map['teacherId']) as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      lessonId: (map['lesson_id'] ?? map['lessonId']) as String?,
      scheduledAt: DateTime.parse(
        (map['scheduled_at'] ?? map['scheduledAt']) as String,
      ),
      durationMinutes:
          (map['duration_minutes'] ?? map['durationMinutes']) as int? ?? 60,
      studentIds:
          (map['student_ids'] ?? map['studentIds'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      isCompleted:
          (map['is_completed'] ?? map['isCompleted']) == 1 ||
          (map['is_completed'] ?? map['isCompleted']) == true,
      createdAt: DateTime.parse(
        (map['created_at'] ?? map['createdAt']) as String,
      ),
      updatedAt: DateTime.parse(
        (map['updated_at'] ?? map['updatedAt']) as String,
      ),
    );
  }

  SessionModel copyWith({
    String? id,
    String? teacherId,
    String? title,
    String? description,
    String? lessonId,
    DateTime? scheduledAt,
    int? durationMinutes,
    List<String>? studentIds,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      description: description ?? this.description,
      lessonId: lessonId ?? this.lessonId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      studentIds: studentIds ?? this.studentIds,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
