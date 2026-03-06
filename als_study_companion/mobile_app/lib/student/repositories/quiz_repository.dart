import 'package:shared_core/shared_core.dart';
import '../../core/database/database_helper.dart';

/// Repository for quiz data operations.
class QuizRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<QuizModel>> getQuizzesByLesson(String lessonId) async {
    final maps = await _db.queryWhere(
      DbConstants.tableQuizzes,
      where: 'lessonId = ? AND isPublished = 1',
      whereArgs: [lessonId],
    );
    return maps.map((m) => QuizModel.fromMap(m)).toList();
  }

  Future<QuizModel?> getQuizById(String id) async {
    final map = await _db.queryById(DbConstants.tableQuizzes, id);
    return map != null ? QuizModel.fromMap(map) : null;
  }

  Future<List<QuestionModel>> getQuestionsByQuiz(String quizId) async {
    final maps = await _db.queryWhere(
      DbConstants.tableQuestions,
      where: 'quizId = ?',
      whereArgs: [quizId],
      orderBy: 'orderIndex ASC',
    );
    return maps.map((m) => QuestionModel.fromMap(m)).toList();
  }

  Future<void> saveQuiz(QuizModel quiz) async {
    await _db.insert(DbConstants.tableQuizzes, quiz.toMap());
  }

  Future<void> saveQuestion(QuestionModel question) async {
    await _db.insert(DbConstants.tableQuestions, question.toMap());
  }

  Future<void> saveQuestions(List<QuestionModel> questions) async {
    for (final q in questions) {
      await _db.insert(DbConstants.tableQuestions, q.toMap());
    }
  }

  Future<void> deleteQuiz(String id) async {
    await _db.delete(DbConstants.tableQuizzes, id);
  }
}
