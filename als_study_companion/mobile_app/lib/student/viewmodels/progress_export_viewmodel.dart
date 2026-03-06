import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_core/shared_core.dart';
import '../../core/database/database_helper.dart';

/// ViewModel for exporting student progress data.
class ProgressExportViewModel extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  bool _isExporting = false;
  String? _exportPath;
  String? _errorMessage;

  bool get isExporting => _isExporting;
  String? get exportPath => _exportPath;
  String? get errorMessage => _errorMessage;

  /// Export student progress as CSV file.
  Future<String?> exportProgressCsv(String studentId) async {
    _isExporting = true;
    _errorMessage = null;
    _exportPath = null;
    notifyListeners();

    try {
      // Fetch progress records
      final progressMaps = await _db.queryWhere(
        DbConstants.tableProgress,
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'last_accessed_at DESC',
      );
      final progressList = progressMaps
          .map((m) => ProgressModel.fromMap(m))
          .toList();

      // Fetch lesson titles for enrichment
      final lessonMaps = await _db.queryAll(DbConstants.tableLessons);
      final lessonMap = <String, String>{};
      for (final m in lessonMaps) {
        lessonMap[m['id'] as String] = m['title'] as String? ?? 'Unknown';
      }

      // Build CSV content
      final buffer = StringBuffer();
      buffer.writeln(
        'Lesson,Subject,Progress (%),Quiz Score,Time Spent (min),Last Accessed',
      );

      for (final p in progressList) {
        final lessonTitle =
            lessonMap[p.lessonId]?.replaceAll(',', ' ') ?? 'Unknown';
        buffer.writeln(
          '$lessonTitle,'
          '${p.lessonId},'
          '${p.progressPercent.toStringAsFixed(1)},'
          '${p.quizScore ?? "N/A"},'
          '${p.timeSpentMinutes},'
          '${p.lastAccessedAt.toIso8601String()}',
        );
      }

      // Summary row
      final avgProgress = progressList.isEmpty
          ? 0.0
          : progressList.fold<double>(0, (s, p) => s + p.progressPercent) /
                progressList.length;
      final totalTime = progressList.fold<int>(
        0,
        (s, p) => s + p.timeSpentMinutes,
      );
      buffer.writeln();
      buffer.writeln('Summary,,,,');
      buffer.writeln('Total Lessons,${progressList.length},,,');
      buffer.writeln('Average Progress,${avgProgress.toStringAsFixed(1)}%,,,');
      buffer.writeln('Total Time,$totalTime min,,,');

      // Write to file
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final filePath = '${dir.path}/progress_export_$timestamp.csv';
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      _exportPath = filePath;
      _isExporting = false;
      notifyListeners();
      return filePath;
    } catch (e) {
      _errorMessage = 'Export failed: ${e.toString()}';
      _isExporting = false;
      notifyListeners();
      return null;
    }
  }
}
