import 'package:shared_core/shared_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/database_helper.dart';

/// Repository for lesson data operations (SQLite local cache & Supabase remote).
class LessonRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ─── SQLite Operations ───

  Future<List<LessonModel>> getLocalLessons() async {
    final maps = await _db.queryAll(DbConstants.tableLessons);
    return maps.map((m) => LessonModel.fromMap(m)).toList();
  }

  Future<List<LessonModel>> getLessonsBySubject(String subject) async {
    final maps = await _db.queryWhere(
      DbConstants.tableLessons,
      where: 'subject = ? AND isPublished = 1',
      whereArgs: [subject],
      orderBy: 'orderIndex ASC',
    );
    return maps.map((m) => LessonModel.fromMap(m)).toList();
  }

  Future<LessonModel?> getLessonById(String id) async {
    final map = await _db.queryById(DbConstants.tableLessons, id);
    return map != null ? LessonModel.fromMap(map) : null;
  }

  Future<void> saveLesson(LessonModel lesson) async {
    await _db.insert(DbConstants.tableLessons, lesson.toMap());
  }

  Future<void> saveLessons(List<LessonModel> lessons) async {
    for (final lesson in lessons) {
      await _db.insert(DbConstants.tableLessons, lesson.toMap());
    }
  }

  Future<void> deleteLesson(String id) async {
    await _db.delete(DbConstants.tableLessons, id);
  }

  // ─── Supabase Remote Operations ───

  Future<List<LessonModel>> fetchRemoteLessons() async {
    try {
      final res = await Supabase.instance.client
          .from('lessons')
          .select()
          .eq('is_published', true)
          .order('order_index', ascending: true);

      final items = List<Map<String, dynamic>>.from(res as List);
      return items.map((m) => LessonModel.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> uploadLesson(LessonModel lesson) async {
    try {
      await Supabase.instance.client.from('lessons').upsert(lesson.toMap());

      // Also save to local DB for offline cache
      await DatabaseHelper.instance.insert(
        DbConstants.tableLessons,
        lesson.toMap(),
      );
    } catch (e) {
      // swallow for now; caller handles user feedback
    }
  }
}
