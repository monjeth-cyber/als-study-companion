import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for Supabase Storage operations.
///
/// Manages uploading, downloading, and deleting files such as
/// lesson videos, images, and learning materials.
class SupabaseStorageService {
  final SupabaseClient _client;

  SupabaseStorageService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static const String _videosBucket = 'lesson-videos';
  static const String _materialsBucket = 'lesson-materials';
  static const String _profilesBucket = 'profile-pictures';

  /// Upload a file from bytes and return the public URL.
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List data,
    String? contentType,
  }) async {
    await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          data,
          fileOptions: contentType != null
              ? FileOptions(contentType: contentType)
              : const FileOptions(),
        );
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Get the public URL for a file.
  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Create a signed URL valid for [expiresIn] seconds.
  Future<String> getSignedUrl(
    String bucket,
    String path, {
    int expiresIn = 3600,
  }) async {
    return _client.storage.from(bucket).createSignedUrl(path, expiresIn);
  }

  /// Delete a file from storage.
  Future<void> deleteFile(String bucket, String path) async {
    await _client.storage.from(bucket).remove([path]);
  }

  /// Upload a lesson video.
  Future<String> uploadLessonVideo({
    required String lessonId,
    required Uint8List videoBytes,
    String fileName = 'video.mp4',
  }) async {
    final path = '$lessonId/$fileName';
    return uploadFile(
      bucket: _videosBucket,
      path: path,
      data: videoBytes,
      contentType: 'video/mp4',
    );
  }

  /// Upload a lesson document/material.
  Future<String> uploadLessonMaterial({
    required String lessonId,
    required Uint8List fileBytes,
    required String fileName,
    String contentType = 'application/pdf',
  }) async {
    final path = '$lessonId/$fileName';
    return uploadFile(
      bucket: _materialsBucket,
      path: path,
      data: fileBytes,
      contentType: contentType,
    );
  }

  /// Upload a user profile image.
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    final path = '$userId/profile.jpg';
    return uploadFile(
      bucket: _profilesBucket,
      path: path,
      data: imageBytes,
      contentType: 'image/jpeg',
    );
  }

  /// List public URLs for all files in a bucket folder.
  Future<List<String>> listFiles(String bucket, String folderPath) async {
    final objects = await _client.storage.from(bucket).list(path: folderPath);
    return objects
        .where((o) => o.name.isNotEmpty)
        .map((o) => getPublicUrl(bucket, '$folderPath/${o.name}'))
        .toList();
  }
}
