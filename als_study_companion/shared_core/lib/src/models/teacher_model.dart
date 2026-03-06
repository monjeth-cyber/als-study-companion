/// Teacher model extending user data with teacher-specific fields.
class TeacherModel {
  final String id;
  final String userId;
  final String? alsCenterId;
  final String employeeId;
  final String specialization;
  final List<String> assignedStudentIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeacherModel({
    required this.id,
    required this.userId,
    this.alsCenterId,
    required this.employeeId,
    required this.specialization,
    this.assignedStudentIds = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'als_center_id': alsCenterId,
      'employee_id': employeeId,
      'specialization': specialization,
      'assigned_student_ids': assignedStudentIds.join(','),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    final rawAssigned = map['assigned_student_ids'] ?? map['assignedStudentIds'];
    List<String> assignedList = [];
    if (rawAssigned is String) {
      assignedList = rawAssigned.split(',').where((s) => s.isNotEmpty).toList();
    } else if (rawAssigned is List) {
      assignedList = rawAssigned.map((e) => e.toString()).toList();
    }

    final rawIsActive = map['is_active'] ?? map['isActive'];
    final isActiveVal = rawIsActive == 1 || rawIsActive == true || rawIsActive == '1';

    return TeacherModel(
      id: map['id'] as String,
      userId: (map['user_id'] ?? map['userId']) as String,
      alsCenterId: (map['als_center_id'] ?? map['alsCenterId']) as String?,
      employeeId: (map['employee_id'] ?? map['employeeId']) as String,
      specialization: (map['specialization'] ?? map['specialization']) as String,
      assignedStudentIds: assignedList,
      isActive: isActiveVal,
      createdAt: DateTime.parse((map['created_at'] ?? map['createdAt']) as String),
      updatedAt: DateTime.parse((map['updated_at'] ?? map['updatedAt']) as String),
    );
  }

  TeacherModel copyWith({
    String? id,
    String? userId,
    String? alsCenterId,
    String? employeeId,
    String? specialization,
    List<String>? assignedStudentIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      alsCenterId: alsCenterId ?? this.alsCenterId,
      employeeId: employeeId ?? this.employeeId,
      specialization: specialization ?? this.specialization,
      assignedStudentIds: assignedStudentIds ?? this.assignedStudentIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
