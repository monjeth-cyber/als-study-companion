import '../enums/sync_status.dart';

/// Lesson model representing educational content.
class LessonModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String gradeLevel;
  final String? videoUrl;
  final String? studyGuideUrl;
  final String? thumbnailUrl;
  final String teacherId;
  final int durationMinutes;
  final int orderIndex;
  final SyncStatus syncStatus;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.gradeLevel,
    this.videoUrl,
    this.studyGuideUrl,
    this.thumbnailUrl,
    required this.teacherId,
    this.durationMinutes = 0,
    this.orderIndex = 0,
    this.syncStatus = SyncStatus.synced,
    this.isPublished = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'grade_level': gradeLevel,
      'video_url': videoUrl,
      'study_guide_url': studyGuideUrl,
      'thumbnail_url': thumbnailUrl,
      'teacher_id': teacherId,
      'duration_minutes': durationMinutes,
      'order_index': orderIndex,
      'sync_status': syncStatus.name,
      'is_published': isPublished ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      subject: map['subject'] as String,
      gradeLevel: (map['grade_level'] ?? map['gradeLevel']) as String,
      videoUrl: (map['video_url'] ?? map['videoUrl']) as String?,
      studyGuideUrl:
          (map['study_guide_url'] ?? map['studyGuideUrl']) as String?,
      thumbnailUrl: (map['thumbnail_url'] ?? map['thumbnailUrl']) as String?,
      teacherId: (map['teacher_id'] ?? map['teacherId']) as String,
      durationMinutes:
          (map['duration_minutes'] ?? map['durationMinutes']) as int? ?? 0,
      orderIndex: (map['order_index'] ?? map['orderIndex']) as int? ?? 0,
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

  LessonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? gradeLevel,
    String? videoUrl,
    String? studyGuideUrl,
    String? thumbnailUrl,
    String? teacherId,
    int? durationMinutes,
    int? orderIndex,
    SyncStatus? syncStatus,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      videoUrl: videoUrl ?? this.videoUrl,
      studyGuideUrl: studyGuideUrl ?? this.studyGuideUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      teacherId: teacherId ?? this.teacherId,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      orderIndex: orderIndex ?? this.orderIndex,
      syncStatus: syncStatus ?? this.syncStatus,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
