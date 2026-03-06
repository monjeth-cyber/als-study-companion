import '../enums/user_role.dart';

/// Base user model for all user types in the system.
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
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final rawIsActive = map['is_active'] ?? map['isActive'];
    final isActiveVal = rawIsActive == 1 || rawIsActive == true || rawIsActive == '1';

    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: (map['full_name'] ?? map['fullName']) as String? ?? '',
      role: UserRole.fromString((map['role'] as String?) ?? 'student'),
      profilePictureUrl: (map['profile_picture_url'] ?? map['profilePictureUrl']) as String?,
      alsCenterId: (map['als_center_id'] ?? map['alsCenterId']) as String?,
      isActive: isActiveVal,
      createdAt: DateTime.parse((map['created_at'] ?? map['createdAt']) as String),
      updatedAt: DateTime.parse((map['updated_at'] ?? map['updatedAt']) as String),
    );
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
    );
  }
}
