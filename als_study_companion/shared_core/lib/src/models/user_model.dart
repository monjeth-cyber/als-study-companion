import '../enums/user_role.dart';

/// Base user model for all user types in the system.
///
/// Student-specific fields: [firstName], [lastName], [studentIdNumber],
/// [dateOfBirth], [age], [phoneNumber], [occupation],
/// [lastSchoolAttended], [lastYearAttended].
///
/// Teacher-specific fields: [phoneNumber], [alsCenterId].
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? profilePictureUrl;
  final String? alsCenterId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Student-specific
  final String? firstName;
  final String? lastName;
  final String? studentIdNumber;
  final DateTime? dateOfBirth;
  final int? age;
  final String? phoneNumber;
  final String? occupation;
  final String? lastSchoolAttended;
  final String? lastYearAttended;

  // Verification & approval
  final bool emailVerified;
  final bool teacherVerified;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.profilePictureUrl,
    this.alsCenterId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.firstName,
    this.lastName,
    this.studentIdNumber,
    this.dateOfBirth,
    this.age,
    this.phoneNumber,
    this.occupation,
    this.lastSchoolAttended,
    this.lastYearAttended,
    this.emailVerified = false,
    this.teacherVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'profile_picture_url': profilePictureUrl,
      'als_center_id': alsCenterId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (studentIdNumber != null) 'student_id_number': studentIdNumber,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String(),
      if (age != null) 'age': age,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (occupation != null) 'occupation': occupation,
      if (lastSchoolAttended != null)
        'last_school_attended': lastSchoolAttended,
      if (lastYearAttended != null) 'last_year_attended': lastYearAttended,
      'email_verified': emailVerified,
      'teacher_verified': teacherVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final rawIsActive = map['is_active'] ?? map['isActive'];
    final isActiveVal =
        rawIsActive == 1 || rawIsActive == true || rawIsActive == '1';

    final rawDob = map['date_of_birth'] ?? map['dateOfBirth'];

    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: (map['full_name'] ?? map['fullName']) as String? ?? '',
      role: UserRole.fromString((map['role'] as String?) ?? 'student'),
      profilePictureUrl:
          (map['profile_picture_url'] ?? map['profilePictureUrl']) as String?,
      alsCenterId: (map['als_center_id'] ?? map['alsCenterId']) as String?,
      isActive: isActiveVal,
      createdAt: DateTime.parse(
        (map['created_at'] ?? map['createdAt']) as String,
      ),
      updatedAt: DateTime.parse(
        (map['updated_at'] ?? map['updatedAt']) as String,
      ),
      firstName: (map['first_name'] ?? map['firstName']) as String?,
      lastName: (map['last_name'] ?? map['lastName']) as String?,
      studentIdNumber:
          (map['student_id_number'] ?? map['studentIdNumber']) as String?,
      dateOfBirth: rawDob != null ? DateTime.tryParse(rawDob as String) : null,
      age: (map['age'] as num?)?.toInt(),
      phoneNumber: (map['phone_number'] ?? map['phoneNumber']) as String?,
      occupation: map['occupation'] as String?,
      lastSchoolAttended:
          (map['last_school_attended'] ?? map['lastSchoolAttended']) as String?,
      lastYearAttended:
          (map['last_year_attended'] ?? map['lastYearAttended']) as String?,
      emailVerified: _parseBool(map['email_verified'] ?? map['emailVerified']),
      teacherVerified: _parseBool(
        map['teacher_verified'] ?? map['teacherVerified'],
      ),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value == 'true';
    return false;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? profilePictureUrl,
    String? alsCenterId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstName,
    String? lastName,
    String? studentIdNumber,
    DateTime? dateOfBirth,
    int? age,
    String? phoneNumber,
    String? occupation,
    String? lastSchoolAttended,
    String? lastYearAttended,
    bool? emailVerified,
    bool? teacherVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      alsCenterId: alsCenterId ?? this.alsCenterId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentIdNumber: studentIdNumber ?? this.studentIdNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      occupation: occupation ?? this.occupation,
      lastSchoolAttended: lastSchoolAttended ?? this.lastSchoolAttended,
      lastYearAttended: lastYearAttended ?? this.lastYearAttended,
      emailVerified: emailVerified ?? this.emailVerified,
      teacherVerified: teacherVerified ?? this.teacherVerified,
    );
  }
}
