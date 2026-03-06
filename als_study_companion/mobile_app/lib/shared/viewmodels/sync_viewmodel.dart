import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/database_helper.dart';

/// ViewModel for managing data synchronization between local SQLite and Firebase.
class SyncViewModel extends ChangeNotifier {
  SyncStatus _status = SyncStatus.synced;
  bool _isSyncing = false;
  String? _lastSyncTime;
  String? _errorMessage;

  SyncStatus get status => _status;
  bool get isSyncing => _isSyncing;
  String? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;

  /// Trigger a full sync cycle.
  Future<void> syncAll() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _status = SyncStatus.syncing;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Push offline data to cloud
      await _pushOfflineData();

      // Step 2: Pull updates from cloud
      await _pullCloudUpdates();

      _status = SyncStatus.synced;
      _lastSyncTime = DateTime.now().toIso8601String();
    } catch (e) {
      _status = SyncStatus.error;
      _errorMessage = e.toString();
    }

    _isSyncing = false;
    notifyListeners();
  }

  /// Push locally stored offline data to Firebase.
  Future<void> _pushOfflineData() async {
    try {
      // Push progress records with syncStatus != 'synced'
      final pending = await DatabaseHelper.instance.queryWhere(
        DbConstants.tableProgress,
        where: "syncStatus != ?",
        whereArgs: ['synced'],
      );

      for (final record in pending) {
        final id = record['id'] as String?;
        if (id == null) continue;
        // upsert to Supabase
        await Supabase.instance.client.from('progress').upsert(record);
        // mark as synced locally
        record['syncStatus'] = 'synced';
        await DatabaseHelper.instance.update(DbConstants.tableProgress, record, id);
      }
    } catch (e) {
      // leave error state to caller
      rethrow;
    }
  }

  /// Pull latest data from Firebase to local SQLite.
  Future<void> _pullCloudUpdates() async {
    try {
      // Pull lessons
      final lessonsRes = await Supabase.instance.client.from('lessons').select();
      final lessons = List<Map<String, dynamic>>.from(lessonsRes as List);
      for (final map in lessons) {
        await DatabaseHelper.instance.insert(DbConstants.tableLessons, map);
      }

      // Pull quizzes
      final quizzesRes = await Supabase.instance.client.from('quizzes').select();
      final quizzes = List<Map<String, dynamic>>.from(quizzesRes as List);
      for (final map in quizzes) {
        await DatabaseHelper.instance.insert(DbConstants.tableQuizzes, map);
      }

      // Pull announcements
      final annRes = await Supabase.instance.client.from('announcements').select();
      final anns = List<Map<String, dynamic>>.from(annRes as List);
      for (final map in anns) {
        await DatabaseHelper.instance.insert(DbConstants.tableAnnouncements, map);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Sync only progress data.
  Future<void> syncProgress() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    try {
      await _pushOfflineData();
      _status = SyncStatus.synced;
    } catch (e) {
      _status = SyncStatus.error;
      _errorMessage = e.toString();
    }

    _isSyncing = false;
    notifyListeners();
  }
}
