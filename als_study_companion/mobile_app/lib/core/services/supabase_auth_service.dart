import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_core/shared_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

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

  /// Register a new student account.
  ///
  /// Creates a Firebase Auth account, sends email verification, then saves
  /// the full student profile to the Supabase `users` table.
  Future<UserModel> registerStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentIdNumber,
    required DateTime dateOfBirth,
    required int age,
    required String phoneNumber,
    String? occupation,
    String? lastSchoolAttended,
    String? lastYearAttended,
    String? alsCenterId,
  }) async {
    // 1. Create Firebase Auth account
    final fbCred = await fb.FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    final fbUser = fbCred.user;
    if (fbUser == null) throw Exception('Firebase account creation failed.');

    // Update display name in Firebase
    await fbUser.updateDisplayName('$firstName $lastName');

    // 2. Send email verification via Firebase
    await fbUser.sendEmailVerification();

    // 3. Sign into Supabase so we have a session (email + password)
    await _client.auth.signUp(email: email, password: password);

    // 4. Save full profile to Supabase `users` table
    final now = DateTime.now();
    final userMap = {
      'id': fbUser.uid,
      'email': email,
      'full_name': '$firstName $lastName',
      'role': UserRole.student.name,
      'als_center_id': alsCenterId,
      'is_active': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'student_id_number': studentIdNumber,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'age': age,
      'phone_number': phoneNumber,
      'occupation': occupation,
      'last_school_attended': lastSchoolAttended,
      'last_year_attended': lastYearAttended,
      'email_verified': false,
      'teacher_verified': false,
    };
    await _client.from('users').upsert(userMap);

    return UserModel.fromMap(Map<String, dynamic>.from(userMap));
  }

  /// Register a new teacher account.
  ///
  /// Creates a Firebase Auth account, sends email verification, then saves
  /// the teacher profile to the Supabase `users` table.
  Future<UserModel> registerTeacher({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? alsCenterId,
  }) async {
    // 1. Create Firebase Auth account
    final fbCred = await fb.FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    final fbUser = fbCred.user;
    if (fbUser == null) throw Exception('Firebase account creation failed.');

    await fbUser.updateDisplayName('$firstName $lastName');

    // 2. Send email verification
    await fbUser.sendEmailVerification();

    // 3. Sign into Supabase
    await _client.auth.signUp(email: email, password: password);

    // 4. Save profile to Supabase
    final now = DateTime.now();
    final userMap = {
      'id': fbUser.uid,
      'email': email,
      'full_name': '$firstName $lastName',
      'role': UserRole.teacher.name,
      'als_center_id': alsCenterId,
      'is_active': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email_verified': false,
      'teacher_verified': false,
    };
    await _client.from('users').upsert(userMap);

    return UserModel.fromMap(Map<String, dynamic>.from(userMap));
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

  /// Check if Firebase email is verified (reloads user first).
  Future<bool> checkFirebaseEmailVerified() async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser == null) return false;
    await fbUser.reload();
    return fb.FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  /// Mark user email as verified in the Supabase users table.
  Future<void> markEmailVerified(String userId) async {
    await _client
        .from('users')
        .update({
          'email_verified': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  /// Approve a teacher account (admin action).
  Future<void> approveTeacher(String userId) async {
    await _client
        .from('users')
        .update({
          'teacher_verified': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  /// Reject / revoke teacher approval.
  Future<void> revokeTeacherApproval(String userId) async {
    await _client
        .from('users')
        .update({
          'teacher_verified': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  /// Send Firebase email verification to current user.
  Future<void> sendFirebaseEmailVerification() async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser != null && !fbUser.emailVerified) {
      await fbUser.sendEmailVerification();
    }
  }

  /// Sign out from Firebase and Supabase.
  Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
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

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Sign in with Google using Firebase Auth, then sync the user into Supabase.
  ///
  /// [role] is required only for NEW users (first sign-in).
  /// Returns [UserModel] on success, throws on failure.
  Future<UserModel?> signInWithGoogle({required UserRole role}) async {
    // Step 1 — Google account picker
    final googleSignIn = kIsWeb
        ? GoogleSignIn(
            clientId:
                '941404387860-o3bd12g934q2rt1segi6t976ch995grq.apps.googleusercontent.com',
          )
        : GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount == null) return null; // user cancelled

    // Step 2 — Get Google credentials
    final googleAuth = await googleAccount.authentication;
    if (googleAuth.idToken == null) {
      throw Exception('Google Sign-In failed: no ID token returned.');
    }

    // Step 3 — Sign into Firebase
    final credential = fb.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    final fbUserCredential = await fb.FirebaseAuth.instance
        .signInWithCredential(credential);
    final fbUser = fbUserCredential.user;
    if (fbUser == null) throw Exception('Firebase sign-in returned null user.');

    // Step 4 — Sign into Supabase with the Google ID token
    final signInRes = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );

    // Validate sign-in response
    if (signInRes.user == null && _client.auth.currentUser == null) {
      // Cleanup Google sign-in if something failed
      try {
        await googleSignIn.disconnect();
      } catch (_) {}
      throw Exception('Supabase sign-in failed: no user in response.');
    }

    // Prefer the Supabase auth user id when looking up the users table.
    final supabaseUserId = signInRes.user?.id ?? _client.auth.currentUser?.id;

    // Step 5 — Ensure user record exists in `users` table
    // Try lookup by Supabase user id first, then by email as a fallback.
    UserModel? existing;
    if (supabaseUserId != null) {
      existing = await _getUserFromDatabase(supabaseUserId);
    }
    if (existing == null) {
      final email = fbUser.email ?? googleAccount.email;
      existing = await _getUserByEmail(email);
    }
    if (existing != null) return existing;

    // First sign-in — create user row. Use Supabase id when available so the
    // users table aligns with the Supabase auth user id.
    final now = DateTime.now();
    final userMap = {
      'id': supabaseUserId ?? fbUser.uid,
      'email': fbUser.email ?? googleAccount.email,
      'full_name': fbUser.displayName ?? googleAccount.displayName ?? '',
      'role': role.name,
      'profile_picture_url': fbUser.photoURL,
      'is_active': true,
      'email_verified': true,
      'teacher_verified': role == UserRole.teacher ? false : true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
    await _client.from('users').upsert(userMap);
    return UserModel.fromMap(Map<String, dynamic>.from(userMap));
  }

  /// Lookup user by email in the `users` table.
  Future<UserModel?> _getUserByEmail(String email) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromMap(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      return null;
    }
  }
}
