import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String email;
  final String name;
  final DateTime createdAt;
   final String? avatarBase64;

  const UserProfile({
    required this.email,
    required this.name,
    required this.createdAt,
     this.avatarBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'avatarBase64': avatarBase64,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
        avatarBase64: json['avatarBase64'] as String?,
    );
  }
}

class AuthService {
  static const _usersKey = 'auth_users';
  static const _currentUserKey = 'auth_current_user';

  Future<Map<String, dynamic>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_usersKey);

    if (usersRaw == null || usersRaw.isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(usersRaw) as Map<String, dynamic>;
  }

  Future<void> _writeUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readUsers();

    if (users.containsKey(normalizedEmail)) {
      throw StateError('Konto z tym adresem e-mail już istnieje.');
    }

    users[normalizedEmail] = {
      'email': normalizedEmail,
      'password': password,
      'name': name.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _writeUsers(users);
    await _setCurrentUser(normalizedEmail);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readUsers();

    if (!users.containsKey(normalizedEmail)) {
      throw StateError('Użytkownik nie istnieje.');
    }

    final user = users[normalizedEmail] as Map<String, dynamic>;
    if (user['password'] != password) {
      throw StateError('Nieprawidłowe hasło.');
    }

    await _setCurrentUser(normalizedEmail);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<void> _setCurrentUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, email);
  }

  Future<UserProfile?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString(_currentUserKey);

    if (currentEmail == null || currentEmail.isEmpty) {
      return null;
    }

    final users = await _readUsers();
    final userRaw = users[currentEmail];
    if (userRaw == null) {
      await prefs.remove(_currentUserKey);
      return null;
    }

    final user = userRaw as Map<String, dynamic>;
    return UserProfile.fromJson(user);
  }
 Future<UserProfile> updateProfile({
    String? name,
    String? avatarBase64,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString(_currentUserKey);

    if (currentEmail == null || currentEmail.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }

    final users = await _readUsers();
    final userRaw = users[currentEmail];

    if (userRaw == null) {
      throw StateError('Nie znaleziono użytkownika.');
    }

    final user = Map<String, dynamic>.from(userRaw as Map<String, dynamic>);

    if (name != null && name.trim().isNotEmpty) {
      user['name'] = name.trim();
    }

    if (avatarBase64 != null) {
      user['avatarBase64'] = avatarBase64;
    }

    users[currentEmail] = user;
    await _writeUsers(users);

    return UserProfile.fromJson(user);
  }
}