import 'package:shared_core/shared_core.dart';
import '../../core/database/database_helper.dart';

/// Repository for quiz creation and management.
class QuizCreatorRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<QuizModel>> getQuizzesByTeacher(String teacherId) async {
    final maps = await _db.queryWhere(
      DbConstants.tableQuizzes,
      where: 'teacherId = ?',
      whereArgs: [teacherId],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((m) => QuizModel.fromMap(m)).toList();
  }

  Future<void> createQuiz(QuizModel quiz) async {
    await _db.insert(DbConstants.tableQuizzes, quiz.toMap());
  }

  Future<void> updateQuiz(QuizModel quiz) async {
    await _db.update(DbConstants.tableQuizzes, quiz.toMap(), quiz.id);
  }

  Future<void> deleteQuiz(String id) async {
    await _db.delete(DbConstants.tableQuizzes, id);
  }

  Future<void> addQuestion(QuestionModel question) async {
    await _db.insert(DbConstants.tableQuestions, question.toMap());
  }

  Future<void> deleteQuestion(String id) async {
    await _db.delete(DbConstants.tableQuestions, id);
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
}
