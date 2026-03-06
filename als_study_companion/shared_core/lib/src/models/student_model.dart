/// Student model extending user data with student-specific fields.
class StudentModel {
  final String id;
  final String userId;
  final String? teacherId;
  final String? alsCenterId;
  final String learnerReferenceNumber;
  final String gradeLevel;
  final DateTime enrollmentDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentModel({
    required this.id,
    required this.userId,
    this.teacherId,
    this.alsCenterId,
    required this.learnerReferenceNumber,
    required this.gradeLevel,
    required this.enrollmentDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'teacher_id': teacherId,
      'als_center_id': alsCenterId,
      'learner_reference_number': learnerReferenceNumber,
      'grade_level': gradeLevel,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    final rawIsActive = map['is_active'] ?? map['isActive'];
    final isActiveVal = rawIsActive == 1 || rawIsActive == true || rawIsActive == '1';

    return StudentModel(
      id: map['id'] as String,
      userId: (map['user_id'] ?? map['userId']) as String,
      teacherId: (map['teacher_id'] ?? map['teacherId']) as String?,
      alsCenterId: (map['als_center_id'] ?? map['alsCenterId']) as String?,
      learnerReferenceNumber: (map['learner_reference_number'] ?? map['learnerReferenceNumber']) as String,
      gradeLevel: (map['grade_level'] ?? map['gradeLevel']) as String,
      enrollmentDate: DateTime.parse((map['enrollment_date'] ?? map['enrollmentDate']) as String),
      isActive: isActiveVal,
      createdAt: DateTime.parse((map['created_at'] ?? map['createdAt']) as String),
      updatedAt: DateTime.parse((map['updated_at'] ?? map['updatedAt']) as String),
    );
  }

  StudentModel copyWith({
    String? id,
    String? userId,
    String? teacherId,
    String? alsCenterId,
    String? learnerReferenceNumber,
    String? gradeLevel,
    DateTime? enrollmentDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      teacherId: teacherId ?? this.teacherId,
      alsCenterId: alsCenterId ?? this.alsCenterId,
      learnerReferenceNumber:
          learnerReferenceNumber ?? this.learnerReferenceNumber,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
