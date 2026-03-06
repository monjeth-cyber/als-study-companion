/// ALS Center model representing a learning center location.
class AlsCenterModel {
  final String id;
  final String name;
  final String address;
  final String region;
  final String? contactNumber;
  final String? headTeacherId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AlsCenterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.region,
    this.contactNumber,
    this.headTeacherId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'region': region,
      'contact_number': contactNumber,
      'head_teacher_id': headTeacherId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AlsCenterModel.fromMap(Map<String, dynamic> map) {
    final rawIsActive = map['is_active'] ?? map['isActive'];
    final isActiveVal = rawIsActive == 1 || rawIsActive == true || rawIsActive == '1';

    return AlsCenterModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      region: map['region'] as String,
      contactNumber: (map['contact_number'] ?? map['contactNumber']) as String?,
      headTeacherId: (map['head_teacher_id'] ?? map['headTeacherId']) as String?,
      isActive: isActiveVal,
      createdAt: DateTime.parse((map['created_at'] ?? map['createdAt']) as String),
      updatedAt: DateTime.parse((map['updated_at'] ?? map['updatedAt']) as String),
    );
  }

  AlsCenterModel copyWith({
    String? id,
    String? name,
    String? address,
    String? region,
    String? contactNumber,
    String? headTeacherId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlsCenterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      region: region ?? this.region,
      contactNumber: contactNumber ?? this.contactNumber,
      headTeacherId: headTeacherId ?? this.headTeacherId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
