import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../../core/services/supabase_auth_service.dart';
import '../../core/local/local_database.dart';
import 'package:drift/drift.dart' as drift;

/// Base ViewModel class for authentication state management.
///
/// Follows MVVM pattern — View → ViewModel → Service → DataSource.
class AuthViewModel extends ChangeNotifier {
  final SupabaseAuthService _authService;
  final LocalDatabase _localDb;

  AuthViewModel({
    required SupabaseAuthService authService,
    required LocalDatabase localDb,
  }) : _authService = authService,
       _localDb = localDb {
    _initAuthListener();
  }

  UserModel? _currentUser;
  UserRole? _currentRole;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  UserRole? get currentRole => _currentRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize auth state listener
  void _initAuthListener() {
    _authService.authStateChanges.listen((authState) async {
      if (authState.session != null) {
        await _loadCurrentUser();
      } else {
        _currentUser = null;
        _currentRole = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });

    // Load initial user if already signed in
    _loadCurrentUser();
  }

  /// Load current user from service
  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUserModel();
      if (user != null) {
        _currentUser = user;
        _currentRole = user.role;
        _isAuthenticated = true;

        // Cache user in local database
        await _cacheUserLocally(user);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  /// Sign in with email and password.
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        _currentUser = user;
        _currentRole = user.role;
        _isAuthenticated = true;

        // Cache user in local database for offline access
        await _cacheUserLocally(user);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid credentials';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _formatErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();

      // Clear local user cache
      if (_currentUser != null) {
        await _localDb.deleteUserById(_currentUser!.id);
      }

      _currentUser = null;
      _currentRole = null;
      _isAuthenticated = false;
    } catch (e) {
      _errorMessage = 'Error signing out: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Register a new user.
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      if (user != null) {
        _currentUser = user;
        _currentRole = user.role;
        _isAuthenticated = true;

        // Cache user in local database
        await _cacheUserLocally(user);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _formatErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cache user in local database for offline access
  Future<void> _cacheUserLocally(UserModel user) async {
    try {
      await _localDb.upsertUser(
        UsersCompanion(
          id: drift.Value(user.id),
          email: drift.Value(user.email),
          fullName: drift.Value(user.fullName),
          role: drift.Value(user.role.name),
          profilePictureUrl: drift.Value(user.profilePictureUrl),
          alsCenterId: drift.Value(user.alsCenterId),
          isActive: drift.Value(user.isActive),
          createdAt: drift.Value(user.createdAt),
          updatedAt: drift.Value(user.updatedAt),
        ),
      );
    } catch (e) {
      debugPrint('Error caching user locally: $e');
    }
  }

  /// Format error messages to be user-friendly
  String _formatErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (error.contains('Email not confirmed')) {
      return 'Please verify your email address';
    } else if (error.contains('User already registered')) {
      return 'An account with this email already exists';
    } else if (error.contains('Password should be at least')) {
      return 'Password must be at least 6 characters';
    }
    return 'An error occurred. Please try again.';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
