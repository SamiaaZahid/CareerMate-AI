import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  int? _currentUserId;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('current_user_id');
  }

  int? get currentUserId => _currentUserId;

  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_currentUserId == null) return null;
    return await DbService.instance.getUserById(_currentUserId!);
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<String?> signUp({required String name, required String email, required String password}) async {
    final cleanEmail = email.trim().toLowerCase();
    final existing = await DbService.instance.getUserByEmail(cleanEmail);
    if (existing != null) return 'Account already exists';
    final hashed = _hashPassword(password);
    final id = await DbService.instance.createUser({
      'name': name.trim(),
      'email': cleanEmail,
      'password': hashed,
    });
    if (id == null) return 'Failed to create account';
    return null;
  }

  Future<String?> login({required String email, required String password}) async {
    final cleanEmail = email.trim().toLowerCase();
    final user = await DbService.instance.getUserByEmail(cleanEmail);
    if (user == null) return 'Invalid credentials';
    final hashed = _hashPassword(password);
    if (user['password'] != hashed) return 'Invalid credentials';
    _currentUserId = user['id'] as int;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', _currentUserId!);
    return null;
  }

  Future<void> logout() async {
    _currentUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }
}
