import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ViewModel for managing users (students, teachers, admins).
class UserManagementViewModel extends ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  UserRole? _filterRole;

  List<UserModel> get users =>
      _filteredUsers.isNotEmpty ? _filteredUsers : _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRole? get filterRole => _filterRole;
  int get totalUsers => _users.length;
  int get totalStudents =>
      _users.where((u) => u.role == UserRole.student).length;
  int get totalTeachers =>
      _users.where((u) => u.role == UserRole.teacher).length;

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await Supabase.instance.client.from('users').select();
      final items = List<Map<String, dynamic>>.from(res as List);
      _users = items.map((m) => UserModel.fromMap(m)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load users: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterByRole(UserRole? role) {
    _filterRole = role;
    if (role == null) {
      _filteredUsers = [];
    } else {
      _filteredUsers = _users.where((u) => u.role == role).toList();
    }
    notifyListeners();
  }

  Future<bool> toggleUserActive(String userId, bool isActive) async {
    try {
        await Supabase.instance.client
          .from('users')
          .update({'is_active': isActive ? 1 : 0})
          .eq('id', userId);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index >= 0) {
        _users[index] = _users[index].copyWith(isActive: isActive);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await Supabase.instance.client.from('users').delete().eq('id', userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
