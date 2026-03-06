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
  int get schemaVersion => 1;

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
