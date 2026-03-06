import 'package:shared_core/shared_core.dart';
import '../../core/database/database_helper.dart';

/// Repository for monitoring student progress.
class StudentMonitorRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<StudentModel>> getStudentsByTeacher(String teacherId) async {
    final maps = await _db.queryWhere(
      DbConstants.tableStudents,
      where: 'teacherId = ?',
      whereArgs: [teacherId],
    );
    return maps.map((m) => StudentModel.fromMap(m)).toList();
  }

  Future<List<ProgressModel>> getStudentProgress(String studentId) async {
    final maps = await _db.queryWhere(
      DbConstants.tableProgress,
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'lastAccessedAt DESC',
    );
    return maps.map((m) => ProgressModel.fromMap(m)).toList();
  }

  Future<StudentModel?> getStudentById(String id) async {
    final map = await _db.queryById(DbConstants.tableStudents, id);
    return map != null ? StudentModel.fromMap(map) : null;
  }
}
