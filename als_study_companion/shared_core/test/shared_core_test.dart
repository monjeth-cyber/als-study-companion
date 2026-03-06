import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  test('UserModel round-trip serialization', () {
    final now = DateTime.now();
    final user = UserModel(
      id: '1',
      email: 'test@example.com',
      fullName: 'Test User',
      role: UserRole.student,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    final map = user.toMap();
    final restored = UserModel.fromMap(map);
    expect(restored.id, '1');
    expect(restored.email, 'test@example.com');
    expect(restored.role, UserRole.student);
  });

  test('UserRole fromString', () {
    expect(UserRole.fromString('student'), UserRole.student);
    expect(UserRole.fromString('teacher'), UserRole.teacher);
    expect(UserRole.fromString('admin'), UserRole.admin);
  });
}
