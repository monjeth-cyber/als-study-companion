import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_core/shared_core.dart';

/// Service for Supabase Authentication operations.
/// Provides auth methods compatible with the existing Firebase interface.
class SupabaseAuthService {
  final SupabaseClient _client;

  SupabaseAuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Current Supabase user.
  User? get currentUser => _client.auth.currentUser;

  /// Auth state stream - emits when auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password.
  /// Returns the [UserModel] from Postgres 'users' table after authentication.
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) return null;
      return _getUserFromDatabase(res.user!.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Register a new user with email and password.
  /// Creates both a Supabase Auth account and a user record in 'users' table.
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? alsCenterId,
  }) async {
    try {
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

      // Insert into 'users' table
      await _client.from('users').insert(userMap);

      return UserModel.fromMap(Map<String, dynamic>.from(userMap));
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Fetch user document from 'users' table by UID.
  Future<UserModel?> _getUserFromDatabase(String uid) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromMap(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      return null;
    }
  }

  /// Get user model for the currently authenticated user.
  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    return _getUserFromDatabase(user.id);
  }

  /// Update user profile in 'users' table.
  Future<void> updateUserProfile(UserModel user) async {
    await _client.from('users').update(user.toMap()).eq('id', user.id);
  }

  /// Delete user record from 'users' table.
  /// Note: Deleting the Supabase Auth account requires admin privileges.
  Future<void> deleteUserRecord(String uid) async {
    await _client.from('users').delete().eq('id', uid);
  }

  /// Check if email is verified.
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  /// Resend verification email.
  Future<void> resendVerificationEmail() async {
    final user = currentUser;
    if (user != null) {
      await _client.auth.resend(type: OtpType.signup, email: user.email);
    }
  }
}
