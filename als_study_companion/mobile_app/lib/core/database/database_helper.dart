import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_core/shared_core.dart';

/// SQLite database helper — singleton for offline-first data storage.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.databaseName);

    return await openDatabase(
      path,
      version: DbConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableUsers} (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        fullName TEXT NOT NULL,
        role TEXT NOT NULL,
        profilePictureUrl TEXT,
        alsCenterId TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Students table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableStudents} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        teacherId TEXT,
        alsCenterId TEXT,
        learnerReferenceNumber TEXT NOT NULL,
        gradeLevel TEXT NOT NULL,
        enrollmentDate TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES ${DbConstants.tableUsers}(id)
      )
    ''');

    // Teachers table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableTeachers} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        alsCenterId TEXT,
        employeeId TEXT NOT NULL,
        specialization TEXT NOT NULL,
        assignedStudentIds TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES ${DbConstants.tableUsers}(id)
      )
    ''');

    // Lessons table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableLessons} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        subject TEXT NOT NULL,
        gradeLevel TEXT NOT NULL,
        videoUrl TEXT,
        studyGuideUrl TEXT,
        thumbnailUrl TEXT,
        teacherId TEXT NOT NULL,
        durationMinutes INTEGER DEFAULT 0,
        orderIndex INTEGER DEFAULT 0,
        syncStatus TEXT DEFAULT 'synced',
        isPublished INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Quizzes table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableQuizzes} (
        id TEXT PRIMARY KEY,
        lessonId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        timeLimitMinutes INTEGER DEFAULT 30,
        passingScore INTEGER DEFAULT 75,
        totalQuestions INTEGER DEFAULT 0,
        teacherId TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'synced',
        isPublished INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (lessonId) REFERENCES ${DbConstants.tableLessons}(id)
      )
    ''');

    // Questions table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableQuestions} (
        id TEXT PRIMARY KEY,
        quizId TEXT NOT NULL,
        questionText TEXT NOT NULL,
        options TEXT NOT NULL,
        correctOptionIndex INTEGER NOT NULL,
        explanation TEXT,
        orderIndex INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (quizId) REFERENCES ${DbConstants.tableQuizzes}(id)
      )
    ''');

    // Student Progress table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableProgress} (
        id TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        lessonId TEXT NOT NULL,
        quizId TEXT,
        progressPercent REAL DEFAULT 0.0,
        quizScore INTEGER,
        timeSpentMinutes INTEGER DEFAULT 0,
        syncStatus TEXT DEFAULT 'synced',
        lastAccessedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Sessions table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableSessions} (
        id TEXT PRIMARY KEY,
        teacherId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        lessonId TEXT,
        scheduledAt TEXT NOT NULL,
        durationMinutes INTEGER DEFAULT 60,
        studentIds TEXT,
        isCompleted INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Downloads table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableDownloads} (
        id TEXT PRIMARY KEY,
        lessonId TEXT NOT NULL,
        studentId TEXT NOT NULL,
        localFilePath TEXT,
        downloadProgress REAL DEFAULT 0.0,
        status TEXT DEFAULT 'notDownloaded',
        fileSizeBytes INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Announcements table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableAnnouncements} (
        id TEXT PRIMARY KEY,
        authorId TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        targetRole TEXT,
        alsCenterId TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // ALS Centers table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableAlsCenters} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        region TEXT NOT NULL,
        contactNumber TEXT,
        headTeacherId TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
  }

  // Generic CRUD operations

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>?> queryById(String table, String id) async {
    final db = await database;
    final results = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAll(String table) async {
    final db = await database;
    return await db.delete(table);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
