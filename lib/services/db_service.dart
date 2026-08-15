import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  DbService._();
  static final DbService instance = DbService._();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'careermate.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            degree TEXT,
            college TEXT,
            year_of_study TEXT,
            preferred_location TEXT,
            skills TEXT,
            career_goals TEXT,
            resume_path TEXT,
            photo_path TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE searches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            query TEXT,
            created_at INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE users ADD COLUMN password TEXT');
          } catch (_) {}
        }

        if (oldVersion < 3) {
          final columns = await db.rawQuery("PRAGMA table_info(users)");
          final existing = columns.map((row) => row['name'] as String).toSet();

          final profileColumns = {
            'degree': 'TEXT',
            'college': 'TEXT',
            'year_of_study': 'TEXT',
            'preferred_location': 'TEXT',
            'skills': 'TEXT',
            'career_goals': 'TEXT',
          };

          for (final entry in profileColumns.entries) {
            if (!existing.contains(entry.key)) {
              await db.execute('ALTER TABLE users ADD COLUMN ${entry.key} ${entry.value}');
            }
          }
        }
      },
    );
  }

  Future<int> upsertUser(Map<String, dynamic> user) async {
    final database = await db;
    // try update by email
    if (user['email'] != null) {
      final existing = await database.query('users', where: 'email=?', whereArgs: [user['email']]);
      if (existing.isNotEmpty) {
        return await database.update('users', user, where: 'email=?', whereArgs: [user['email']]);
      }
    }
    return await database.insert('users', user);
  }

  Future<int?> createUser(Map<String, dynamic> user) async {
    try {
      final database = await db;
      return await database.insert('users', user);
    } catch (e) {
      if (kIsWeb) {
        return await _createUserWebFallback(user);
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final database = await db;
      final rows = await database.query('users', where: 'email=?', whereArgs: [email]);
      if (rows.isEmpty) return null;
      return rows.first;
    } catch (e) {
      if (kIsWeb) {
        return await _getUserByEmailWebFallback(email);
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final database = await db;
      final rows = await database.query('users', where: 'id=?', whereArgs: [id]);
      if (rows.isEmpty) return null;
      return rows.first;
    } catch (e) {
      if (kIsWeb) {
        return await _getUserByIdWebFallback(id);
      }
      return null;
    }
  }

  Future<int> updateUserById(int id, Map<String, dynamic> values) async {
    try {
      final database = await db;
      return await database.update('users', values, where: 'id=?', whereArgs: [id]);
    } catch (e) {
      if (kIsWeb) {
        return await _updateUserByIdWebFallback(id, values);
      }
      return 0;
    }
  }

  Future<bool> userExists(String email, String password) async {
    try {
      final database = await db;
      final result = await database.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      return result.isNotEmpty;
    } catch (e) {
      if (kIsWeb) {
        final user = await _getUserByEmailWebFallback(email);
        return user != null && user['password'] == password;
      }
      return false;
    }
  }

  Future<int> addSearch(int userId, String query) async {
    try {
      final database = await db;
      return await database.insert('searches', {
        'user_id': userId,
        'query': query,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      if (kIsWeb) {
        return await _addSearchWebFallback(userId, query);
      }
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getSearches(int userId) async {
    try {
      final database = await db;
      return await database.query('searches', where: 'user_id=?', whereArgs: [userId], orderBy: 'created_at DESC');
    } catch (e) {
      if (kIsWeb) {
        return await _getSearchesWebFallback(userId);
      }
      return const [];
    }
  }

  Future<int> _createUserWebFallback(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('careermate_users') ?? [];
    final users = list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    final nextId = users.isEmpty
        ? 1
        : users.map((item) => (item['id'] as int?) ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    final newUser = {...user, 'id': nextId};
    users.add(newUser);
    await prefs.setStringList(
      'careermate_users',
      users.map((item) => jsonEncode(item)).toList(),
    );
    return nextId;
  }

  Future<Map<String, dynamic>?> _getUserByEmailWebFallback(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('careermate_users') ?? [];
    for (final item in list) {
      final user = jsonDecode(item) as Map<String, dynamic>;
      if ((user['email'] ?? '').toString().toLowerCase() == email.toLowerCase()) {
        return user;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getUserByIdWebFallback(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('careermate_users') ?? [];
    for (final item in list) {
      final user = jsonDecode(item) as Map<String, dynamic>;
      if ((user['id'] as int?) == id) {
        return user;
      }
    }
    return null;
  }

  Future<int> _updateUserByIdWebFallback(int id, Map<String, dynamic> values) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('careermate_users') ?? [];
    final updated = <Map<String, dynamic>>[];
    bool found = false;
    for (final item in list) {
      final user = jsonDecode(item) as Map<String, dynamic>;
      if ((user['id'] as int?) == id) {
        final merged = {...user, ...values};
        updated.add(merged);
        found = true;
      } else {
        updated.add(user);
      }
    }
    if (!found) return 0;
    await prefs.setStringList(
      'careermate_users',
      updated.map((item) => jsonEncode(item)).toList(),
    );
    return 1;
  }

  Future<int> _addSearchWebFallback(int userId, String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('careermate_searches') ?? [];
    final searches = list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    final nextId = searches.isEmpty
        ? 1
        : searches.map((item) => (item['id'] as int?) ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    searches.add({
      'id': nextId,
      'user_id': userId,
      'query': query,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    await prefs.setStringList(
      'careermate_searches',
      searches.map((item) => jsonEncode(item)).toList(),
    );
    return nextId;
  }

  Future<List<Map<String, dynamic>>> _getSearchesWebFallback(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('careermate_searches') ?? [];
    final searches = list
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .where((item) => (item['user_id'] as int?) == userId)
        .toList();
    searches.sort((a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int));
    return searches;
  }
}
