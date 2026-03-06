import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  group('UserModel', () {
    test('round-trip serialization', () {
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

    test('emailVerified and teacherVerified round-trip', () {
      final now = DateTime.now();
      final user = UserModel(
        id: '2',
        email: 'teacher@test.com',
        fullName: 'Teacher',
        role: UserRole.teacher,
        emailVerified: true,
        teacherVerified: false,
        createdAt: now,
        updatedAt: now,
      );
      final map = user.toMap();
      expect(map['email_verified'], true);
      expect(map['teacher_verified'], false);

      final restored = UserModel.fromMap(map);
      expect(restored.emailVerified, true);
      expect(restored.teacherVerified, false);
    });

    test('copyWith preserves fields', () {
      final now = DateTime.now();
      final user = UserModel(
        id: '1',
        email: 'a@b.com',
        fullName: 'A',
        role: UserRole.student,
        createdAt: now,
        updatedAt: now,
      );
      final copied = user.copyWith(emailVerified: true);
      expect(copied.emailVerified, true);
      expect(copied.email, 'a@b.com');
    });
  });

  group('UserRole', () {
    test('fromString', () {
      expect(UserRole.fromString('student'), UserRole.student);
      expect(UserRole.fromString('teacher'), UserRole.teacher);
      expect(UserRole.fromString('admin'), UserRole.admin);
    });
  });

  group('LessonModel', () {
    test('round-trip serialization', () {
      final now = DateTime.now();
      final lesson = LessonModel(
        id: 'l1',
        title: 'Math Basics',
        description: 'Intro to math',
        subject: 'Math',
        gradeLevel: 'Elementary',
        teacherId: 't1',
        durationMinutes: 30,
        isPublished: true,
        createdAt: now,
        updatedAt: now,
      );
      final map = lesson.toMap();
      final restored = LessonModel.fromMap(map);
      expect(restored.title, 'Math Basics');
      expect(restored.isPublished, true);
      expect(restored.durationMinutes, 30);
    });

    test('fromMap handles both key formats', () {
      final map = {
        'id': 'l1',
        'title': 'Test',
        'description': 'Desc',
        'subject': 'Sci',
        'gradeLevel': 'JHS',
        'teacherId': 't1',
        'durationMinutes': 45,
        'isPublished': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      final lesson = LessonModel.fromMap(map);
      expect(lesson.gradeLevel, 'JHS');
      expect(lesson.teacherId, 't1');
    });
  });

  group('StudentModel', () {
    test('guardian fields serialization', () {
      final now = DateTime.now();
      final student = StudentModel(
        id: 's1',
        userId: 'u1',
        learnerReferenceNumber: '123456789012',
        gradeLevel: 'Elementary',
        enrollmentDate: now,
        guardianName: 'Maria Santos',
        guardianContact: '+639123456789',
        createdAt: now,
        updatedAt: now,
      );
      final map = student.toMap();
      expect(map['guardian_name'], 'Maria Santos');
      expect(map['guardian_contact'], '+639123456789');

      final restored = StudentModel.fromMap(map);
      expect(restored.guardianName, 'Maria Santos');
      expect(restored.guardianContact, '+639123456789');
    });
  });

  group('ProgressModel', () {
    test('round-trip serialization', () {
      final now = DateTime.now();
      final progress = ProgressModel(
        id: 'p1',
        studentId: 's1',
        lessonId: 'l1',
        progressPercent: 75.5,
        quizScore: 85,
        timeSpentMinutes: 42,
        lastAccessedAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final map = progress.toMap();
      final restored = ProgressModel.fromMap(map);
      expect(restored.progressPercent, 75.5);
      expect(restored.quizScore, 85);
      expect(restored.timeSpentMinutes, 42);
    });
  });

  group('DownloadModel', () {
    test('status round-trip', () {
      final now = DateTime.now();
      final download = DownloadModel(
        id: 'd1',
        lessonId: 'l1',
        studentId: 's1',
        status: DownloadStatus.downloaded,
        downloadProgress: 1.0,
        fileSizeBytes: 1048576,
        createdAt: now,
        updatedAt: now,
      );
      final map = download.toMap();
      final restored = DownloadModel.fromMap(map);
      expect(restored.status, DownloadStatus.downloaded);
      expect(restored.fileSizeBytes, 1048576);
    });
  });

  group('Validators', () {
    test('validateEmail', () {
      expect(Validators.validateEmail(null), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('bad'), isNotNull);
      expect(Validators.validateEmail('good@email.com'), isNull);
    });

    test('validatePassword', () {
      expect(Validators.validatePassword(null), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('short'), isNotNull);
      expect(Validators.validatePassword('12345678'), isNull);
      expect(Validators.validatePassword('longpassword'), isNull);
    });

    test('validateConfirmPassword', () {
      expect(Validators.validateConfirmPassword('abc', 'def'), isNotNull);
      expect(Validators.validateConfirmPassword('same', 'same'), isNull);
    });

    test('validateFullName', () {
      expect(Validators.validateFullName(null), isNotNull);
      expect(Validators.validateFullName(''), isNotNull);
      expect(Validators.validateFullName('A'), isNotNull);
      expect(Validators.validateFullName('AB'), isNull);
      expect(Validators.validateFullName('John Doe'), isNull);
    });

    test('validatePhone', () {
      expect(Validators.validatePhone(null), isNull); // Optional
      expect(Validators.validatePhone('abc'), isNotNull);
      expect(Validators.validatePhone('+639123456789'), isNull);
    });

    test('validateLearnerReferenceNumber', () {
      expect(Validators.validateLearnerReferenceNumber(null), isNotNull);
      expect(Validators.validateLearnerReferenceNumber('123'), isNotNull);
      expect(Validators.validateLearnerReferenceNumber('123456789012'), isNull);
      expect(
        Validators.validateLearnerReferenceNumber('12345678901a'),
        isNotNull,
      );
    });

    test('validateStudentIdNumber', () {
      expect(Validators.validateStudentIdNumber(null), isNull); // Optional
      expect(Validators.validateStudentIdNumber('AB'), isNotNull);
      expect(Validators.validateStudentIdNumber('STU-001'), isNull);
      expect(Validators.validateStudentIdNumber('bad@id'), isNotNull);
    });

    test('validateGuardianName is optional', () {
      expect(Validators.validateGuardianName(null), isNull); // Optional
      expect(Validators.validateGuardianName(''), isNull); // Optional
      expect(Validators.validateGuardianName('A'), isNotNull); // Too short
      expect(Validators.validateGuardianName('Maria Santos'), isNull);
    });

    test(
      'validateGuardianContact requires phone when guardian name provided',
      () {
        expect(
          Validators.validateGuardianContact(null, guardianName: 'Maria'),
          isNotNull,
        );
        expect(
          Validators.validateGuardianContact(
            '+639123456789',
            guardianName: 'Maria',
          ),
          isNull,
        );
        expect(
          Validators.validateGuardianContact(null, guardianName: null),
          isNull,
        );
      },
    );

    test('validateDateOfBirth', () {
      expect(Validators.validateDateOfBirth(null), isNotNull);
      expect(
        Validators.validateDateOfBirth(DateTime.now()),
        isNotNull, // Too young
      );
      expect(
        Validators.validateDateOfBirth(DateTime(2000, 1, 1)),
        isNull, // Valid
      );
    });

    test('validateGradeLevel', () {
      expect(Validators.validateGradeLevel(null), isNotNull);
      expect(Validators.validateGradeLevel(''), isNotNull);
      expect(Validators.validateGradeLevel('BLP'), isNull);
      expect(Validators.validateGradeLevel('Elementary'), isNull);
      expect(Validators.validateGradeLevel('Junior High School'), isNull);
      expect(Validators.validateGradeLevel('Senior High School'), isNull);
      expect(Validators.validateGradeLevel('ALS-EST Elementary'), isNull);
      expect(Validators.validateGradeLevel('ALS-EST JHS'), isNull);
      expect(Validators.validateGradeLevel('Invalid Level'), isNotNull);
      expect(Validators.validateGradeLevel('JHS'), isNotNull);
    });
  });

  group('SyncStatus', () {
    test('fromString', () {
      expect(SyncStatus.fromString('synced'), SyncStatus.synced);
      expect(SyncStatus.fromString('syncing'), SyncStatus.syncing);
      expect(SyncStatus.fromString('error'), SyncStatus.error);
    });
  });

  group('DownloadStatus', () {
    test('fromString', () {
      expect(
        DownloadStatus.fromString('downloaded'),
        DownloadStatus.downloaded,
      );
      expect(DownloadStatus.fromString('failed'), DownloadStatus.failed);
      expect(
        DownloadStatus.fromString('notDownloaded'),
        DownloadStatus.notDownloaded,
      );
    });

    test('displayName', () {
      expect(DownloadStatus.downloading.displayName, 'Downloading');
      expect(DownloadStatus.failed.displayName, 'Failed');
    });
  });
}
