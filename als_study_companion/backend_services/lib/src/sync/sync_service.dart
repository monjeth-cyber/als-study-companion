import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_core/shared_core.dart';
import '../supabase/supabase_database_service.dart';

/// Central synchronization service for offline-first architecture.
///
/// Handles pushing locally-modified records to Firestore and pulling
/// remote changes down to the local SQLite database.
class SyncService {
  final SupabaseDatabaseService _firestoreService;
  final Connectivity _connectivity;

  SyncStatus _status = SyncStatus.synced;
  SyncStatus get status => _status;

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncService({
    required SupabaseDatabaseService firestoreService,
    Connectivity? connectivity,
  }) : _firestoreService = firestoreService,
       _connectivity = connectivity ?? Connectivity();

  /// Check if the device currently has internet connectivity.
  Future<bool> get hasConnectivity async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Perform a full sync cycle: push local changes, then pull remote changes.
  ///
  /// [pushCallback] – called to push locally-modified records to Firestore.
  /// [pullCallback] – called to pull latest records from Firestore to SQLite.
  Future<SyncResult> performSync({
    required Future<int> Function() pushCallback,
    required Future<int> Function() pullCallback,
  }) async {
    if (_status == SyncStatus.syncing) {
      return SyncResult(
        pushed: 0,
        pulled: 0,
        success: false,
        message: 'Sync already in progress',
      );
    }

    if (!await hasConnectivity) {
      _status = SyncStatus.error;
      return SyncResult(
        pushed: 0,
        pulled: 0,
        success: false,
        message: 'No internet connection',
      );
    }

    _status = SyncStatus.syncing;

    try {
      // Phase 1: Push local changes to Firestore
      final pushed = await pushCallback();

      // Phase 2: Pull remote changes to local DB
      final pulled = await pullCallback();

      _status = SyncStatus.synced;
      _lastSyncTime = DateTime.now();

      return SyncResult(
        pushed: pushed,
        pulled: pulled,
        success: true,
        message: 'Sync completed',
      );
    } catch (e) {
      _status = SyncStatus.error;
      return SyncResult(
        pushed: 0,
        pulled: 0,
        success: false,
        message: 'Sync failed: $e',
      );
    }
  }

  /// Quick push-only sync for a single collection.
  Future<void> pushDocuments(
    String collection,
    List<Map<String, dynamic>> documents,
  ) async {
    if (!await hasConnectivity) return;

    for (final doc in documents) {
      final docId = doc['id'] as String?;
      if (docId != null) {
        await _firestoreService.addDocument(collection, docId, doc);
      }
    }
  }

  /// Pull documents from a Firestore collection.
  Future<List<Map<String, dynamic>>> pullDocuments(String collection) async {
    if (!await hasConnectivity) return [];
    return _firestoreService.getCollection(collection);
  }

  /// Pull documents with a filter.
  Future<List<Map<String, dynamic>>> pullFilteredDocuments(
    String collection, {
    required String field,
    required dynamic isEqualTo,
  }) async {
    if (!await hasConnectivity) return [];
    return _firestoreService.queryCollection(
      collection,
      field: field,
      isEqualTo: isEqualTo,
    );
  }
}

/// Result of a sync operation.
class SyncResult {
  final int pushed;
  final int pulled;
  final bool success;
  final String message;

  const SyncResult({
    required this.pushed,
    required this.pulled,
    required this.success,
    required this.message,
  });

  @override
  String toString() =>
      'SyncResult(pushed: $pushed, pulled: $pulled, success: $success, message: $message)';
}
