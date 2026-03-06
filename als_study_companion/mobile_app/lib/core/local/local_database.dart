import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_database.g.dart';

/// Users table - mirrors UserModel for offline caching
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get fullName => text()();
  TextColumn get role => text()();
  TextColumn get profilePictureUrl => text().nullable()();
  TextColumn get alsCenterId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Student-specific
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get studentIdNumber => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get occupation => text().nullable()();
  TextColumn get lastSchoolAttended => text().nullable()();
  TextColumn get lastYearAttended => text().nullable()();

  // Verification flags
  BoolColumn get emailVerified =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get teacherVerified =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync queue table - tracks pending operations for offline sync
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'user', 'lesson', 'progress', etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'insert', 'update', 'delete'
  TextColumn get payload => text()(); // JSON payload
  TextColumn get status => text()(); // 'pending', 'syncing', 'synced', 'failed'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptedAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Users, SyncQueue])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(users, users.firstName);
        await m.addColumn(users, users.lastName);
        await m.addColumn(users, users.studentIdNumber);
        await m.addColumn(users, users.dateOfBirth);
        await m.addColumn(users, users.age);
        await m.addColumn(users, users.phoneNumber);
        await m.addColumn(users, users.occupation);
        await m.addColumn(users, users.lastSchoolAttended);
        await m.addColumn(users, users.lastYearAttended);
      }
      if (from < 3) {
        await m.addColumn(users, users.emailVerified);
        await m.addColumn(users, users.teacherVerified);
      }
    },
  );

  // User operations
  Future<User?> getUserById(String id) async {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertUser(UsersCompanion user) async {
    await into(users).insertOnConflictUpdate(user);
  }

  Future<void> deleteUserById(String id) async {
    await (delete(users)..where((u) => u.id.equals(id))).go();
  }

  Future<List<User>> getAllUsers() async {
    return select(users).get();
  }

  // Sync queue operations
  Future<int> addToSyncQueue({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  }) async {
    return into(syncQueue).insert(
      SyncQueueCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        payload: payload,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<List<SyncQueueData>> getPendingSyncItems() async {
    return (select(syncQueue)
          ..where((s) => s.status.equals('pending'))
          ..orderBy([(s) => OrderingTerm(expression: s.createdAt)]))
        .get();
  }

  Future<void> updateSyncItemStatus(int id, String status) async {
    await (update(syncQueue)..where((s) => s.id.equals(id))).write(
      SyncQueueCompanion(
        status: Value(status),
        lastAttemptedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> incrementSyncRetryCount(int id) async {
    final item = await (select(
      syncQueue,
    )..where((s) => s.id.equals(id))).getSingle();
    await (update(syncQueue)..where((s) => s.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: Value(item.retryCount + 1),
        lastAttemptedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> removeSyncItem(int id) async {
    await (delete(syncQueue)..where((s) => s.id.equals(id))).go();
  }

  Future<void> clearSyncedItems() async {
    await (delete(syncQueue)..where((s) => s.status.equals('synced'))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final docs = await getApplicationDocumentsDirectory();
    final file = File(p.join(docs.path, 'als_local.sqlite'));
    return NativeDatabase(file);
  });
}
