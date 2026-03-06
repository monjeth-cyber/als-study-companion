import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_core/shared_core.dart';

/// Service for Supabase Authentication and user profile operations.
class SupabaseAuthService {
  final SupabaseClient _client;

  SupabaseAuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Current authenticated user.
  User? get currentUser => _client.auth.currentUser;

  /// Auth state change stream.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password.
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user == null) return null;
    return _getUserFromDatabase(res.user!.id);
  }

  /// Register a new user.
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? alsCenterId,
  }) async {
    final res = await _client.auth.signUp(email: email, password: password);
    if (res.user == null) return null;

    final now = DateTime.now();
    final userMap = {
      'id': res.user!.id,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'als_center_id': alsCenterId,
      'is_active': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    await _client.from('users').insert(userMap);
    return UserModel.fromMap(Map<String, dynamic>.from(userMap));
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Get user model for the currently authenticated user.
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    return _getUserFromDatabase(user.id);
  }

  /// Update user profile.
  Future<void> updateUserProfile(UserModel user) async {
    await _client.from('users').update(user.toMap()).eq('id', user.id);
  }

  /// Delete user record.
  Future<void> deleteUserRecord(String uid) async {
    await _client.from('users').delete().eq('id', uid);
  }

  /// Whether the current user's email is verified.
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  Future<UserModel?> _getUserFromDatabase(String uid) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (response == null) return null;
      return UserModel.fromMap(Map<String, dynamic>.from(response as Map));
    } catch (_) {
      return null;
    }
  }
}
