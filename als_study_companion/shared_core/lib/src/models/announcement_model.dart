/// Announcement model for teacher/admin communications.
class AnnouncementModel {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final String? targetRole; // 'student', 'teacher', or null for all
  final String? alsCenterId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnnouncementModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    this.targetRole,
    this.alsCenterId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author_id': authorId,
      'title': title,
      'content': content,
      'target_role': targetRole,
      'als_center_id': alsCenterId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    final rawIsActive = map['is_active'] ?? map['isActive'];
    final isActiveVal = rawIsActive == 1 || rawIsActive == true || rawIsActive == '1';

    return AnnouncementModel(
      id: (map['id'] ?? map['id']) as String,
      authorId: (map['author_id'] ?? map['authorId']) as String,
      title: (map['title'] ?? map['title']) as String,
      content: (map['content'] ?? map['content']) as String,
      targetRole: (map['target_role'] ?? map['targetRole']) as String?,
      alsCenterId: (map['als_center_id'] ?? map['alsCenterId']) as String?,
      isActive: isActiveVal,
      createdAt: DateTime.parse((map['created_at'] ?? map['createdAt']) as String),
      updatedAt: DateTime.parse((map['updated_at'] ?? map['updatedAt']) as String),
    );
  }

  AnnouncementModel copyWith({
    String? id,
    String? authorId,
    String? title,
    String? content,
    String? targetRole,
    String? alsCenterId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      targetRole: targetRole ?? this.targetRole,
      alsCenterId: alsCenterId ?? this.alsCenterId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
